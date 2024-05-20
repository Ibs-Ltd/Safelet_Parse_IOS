//
//  GetPhoneContactsManager.m
//  Safelet
//
//  Created by Alex Motoc on 01/11/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "User+Requests.h"
#import "GetPhoneContactsManager.h"
#import "PhoneContact.h"
#import "FetchParseUsersForPhoneUsers.h"
#import "Utils.h"
#import "SLError.h"
#import <APAddressBook/APContact.h>
#import <APAddressBook/APAddressBook.h>
#import <APAddressBook/APName.h>

@implementation GetPhoneContactsManager

+ (void)fetchRawContacts:(void(^)(NSArray <APContact *> *contacts, NSError *error))completion {
    APAddressBook *addressBook = [[APAddressBook alloc] init];
    
    // don't retrieve contacts that don't have at least one phone number
    addressBook.filterBlock = ^BOOL(APContact *contact) {
        return contact.phones.count > 0;
    };
    
    // retrieve the name, phone number, email and image for a contact
    addressBook.fieldsMask = APContactFieldName | APContactFieldThumbnail |
    APContactFieldPhonesOnly | APContactFieldEmailsOnly;
    
    [addressBook requestAccess:^(BOOL granted, NSError * _Nullable error) {
        if (!granted) {
            NSError *err = [NSError errorWithDomain:SLSafeletErrorDomain
                                               code:SLErrorCodeNoContactsPermission
                                           userInfo:nil];
            
            completion(nil, err);
        } else {
            [addressBook loadContacts:^(NSArray<APContact *> *contacts, NSError *error) {
                completion(contacts, error);
            }];
        }
    }];
}

+ (void)fetchPhoneContacts:(void (^)(NSArray<PhoneContact *> *, NSError *))completion {
    [self fetchRawContacts:^(NSArray<APContact *> *contacts, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        NSMutableArray <PhoneContact *> * finalResults = [NSMutableArray array];
        
        for (APContact *contact in contacts) {
            NSArray <NSString *> *stringPhones = [contact.phones valueForKey:@"number"];
            
            for (NSString *stringPhone in stringPhones) {
                PhoneContact *phoneContact = [[PhoneContact alloc] initWithFirstName:contact.name.firstName
                                                                            lastName:contact.name.lastName
                                                                         phoneNumber:stringPhone
                                                                               image:contact.thumbnail];
                [finalResults addObject:phoneContact];
            }
        }
        
        completion(finalResults, nil);
    }];
}

+ (void)fetchPhoneContactsMatchedWithParseUsers:(void (^)(NSArray<PhoneContact *> *, NSError *))completion {
    [self fetchRawContacts:^(NSArray<APContact *> *contacts, NSError *error) {
        if (error) {
            completion(nil, error);
            return;
        }
        
        NSMutableArray <PhoneContact *> *finalResults = [NSMutableArray array];
        NSMutableDictionary <NSString *, APContact *> *revContacts = [NSMutableDictionary dictionary]; // for easy access when building final result
        NSMutableArray <NSString *> *phoneNumbers = [NSMutableArray array];
        
        for (APContact *contact in contacts) {
            NSArray <NSString *> *contactPhones = [contact.phones valueForKey:@"number"];
            [phoneNumbers addObjectsFromArray:contactPhones];
            for (NSString *contactPhone in contactPhones) { // build reversed dict
                revContacts[contactPhone] = contact;
            }
        }
        
        FetchParseUsersForPhoneUsers *request = [FetchParseUsersForPhoneUsers requestWithPhoneNumbers:phoneNumbers];
        [request setRequestCompletionBlock:^(MatchedParseUsers* _Nullable response,
                                             NSError* _Nullable error) {
            if (error) {
                completion(nil, error);
            } else {
                void (^map)(NSString *, User *, APContact *, NSDictionary *) =
                ^void(NSString *number, User *user, APContact *apContact, NSDictionary *options) {
                    PhoneContact *contact = [[PhoneContact alloc] initWithFirstName:apContact.name.firstName
                                                                           lastName:apContact.name.lastName
                                                                        phoneNumber:number
                                                                           imageURL:user.userImage.url
                                                                        parseUserId:user.objectId
                                                                            options:options];
                    [finalResults addObject:contact];
                };
                
                [response.uninvited enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, User * _Nonnull obj, BOOL * _Nonnull stop) {
                    map(key, obj, revContacts[key], nil);
                }];
                [response.invited enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, User * _Nonnull obj, BOOL * _Nonnull stop) {
                    map(key, obj, revContacts[key], @{kPhoneContactOptionInvited:@YES});
                }];
                [response.guardians enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, User * _Nonnull obj, BOOL * _Nonnull stop) {
                    map(key, obj, revContacts[key], @{kPhoneContactOptionGuardian:@YES});
                }];
                for (NSString *number in response.smsInvited) {
                    APContact *contact = revContacts[number];
                    PhoneContact *phoneContact = [[PhoneContact alloc] initWithFirstName:contact.name.firstName
                                                                                lastName:contact.name.lastName
                                                                             phoneNumber:number
                                                                                   image:contact.thumbnail
                                                                            isSMSInvited:YES];
                    [finalResults addObject:phoneContact];
                }
                for (NSString *number in response.unmatched) {
                    APContact *contact = revContacts[number];
                    PhoneContact *phoneContact = [[PhoneContact alloc] initWithFirstName:contact.name.firstName
                                                                                lastName:contact.name.lastName
                                                                             phoneNumber:number
                                                                                   image:contact.thumbnail];
                    [finalResults addObject:phoneContact];
                }
                
                completion(finalResults, nil);
            }
        }];
        
        request.showsProgressIndicator = NO;
        [request runRequest];
    }];
}

#pragma mark - Utils

+ (void)fetchContactsPhoneNumbersAndEmails:(void(^)(NSArray <NSString *> *phoneNumbers, NSArray <NSString *> *emails, NSError *error))completion {
    [self fetchRawContacts:^(NSArray<APContact *> *contacts, NSError *error) {
        if (error) {
            completion(nil, nil, error);
            return;
        }
        
        NSMutableArray <NSString *> *emails = [NSMutableArray array];
        NSMutableArray <NSString *> *phoneNumbers = [NSMutableArray array];
        
        for (APContact *contact in contacts) {
            [emails addObjectsFromArray:[contact.emails valueForKey:@"address"]];
            [phoneNumbers addObjectsFromArray:[contact.phones valueForKey:@"number"]];
        }
        
        completion(phoneNumbers, emails, nil);
    }];
}

+ (NSArray <NSArray *> *)partitionObjects:(NSArray <PhoneContact *> *)array {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for (int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (id object in array) {
        NSInteger index = [collation sectionForObject:object collationStringSelector:@selector(formattedName)];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    //sort each section
    for (NSMutableArray *section in unsortedSections) {
        NSArray *sortedArray = [section sortedArrayUsingComparator:^NSComparisonResult(PhoneContact *firstObject, PhoneContact *secondObject) {
            NSComparisonResult res = [[firstObject formattedName] compare:[secondObject formattedName]];
            if (res == NSOrderedSame) {
                return [@(firstObject.status) compare:@(secondObject.status)];
            }
            return res;
        }];
        
        [sections addObject:sortedArray];
    }
    return sections;
}

@end
