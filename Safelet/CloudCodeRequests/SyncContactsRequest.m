//
//  SyncContactsRequest.m
//  Safelet
//
//  Created by Alex Motoc on 25/05/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SyncContactsRequest.h"
#import "PhoneContact.h"

@interface SyncContactsRequest ()
@property (strong, nonatomic) NSArray <PhoneContact *> *contactsList;
@property (strong, nonatomic) User *user;
@end

@implementation SyncContactsRequest

+ (instancetype)requestWithUser:(User *)user contactsList:(NSArray<PhoneContact *> *)contactsList {
    SyncContactsRequest *request = [self request];
    request.user = user;
    request.contactsList = contactsList;
    request.showsProgressIndicator = NO;
    return request;
}

- (NSString *)requestURL {
    return @"syncUserPhoneContacts";
}

- (NSDictionary *)params {
    NSMutableArray <NSDictionary <NSString *, NSString *> *> *contacts = [NSMutableArray array];
    for (PhoneContact *contact in self.contactsList) {
        NSDictionary *contactDict = @{@"phoneNumber":contact.phoneNumber, @"contactName":[contact formattedName]};
        [contacts addObject:contactDict];
    }
    
    return @{
             @"contacts":contacts
             };
}

@end
