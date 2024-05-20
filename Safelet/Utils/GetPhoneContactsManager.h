//
//  GetPhoneContactsManager.h
//  Safelet
//
//  Created by Alex Motoc on 01/11/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhoneContact, APContact;
@interface GetPhoneContactsManager : NSObject

/**
 Gets the list of phone contacts unaltered, as they are extracted by the APContacts pod

 @param completion completion block
 */
+ (void)fetchRawContacts:(void(^)(NSArray <APContact *> *contacts, NSError *error))completion;

/**
 Gets the list of contacts from the Contacts app

 @param completion completion block
 */
+ (void)fetchPhoneContacts:(void(^)(NSArray <PhoneContact *> *contacts, NSError *error))completion;

/**
 Gets the list of contacts from the Contacts app. The contacts are also matched with the users on Parse such that we know which contact is also a Safelet user

 @param completion - the completion block
 */
+ (void)fetchPhoneContactsMatchedWithParseUsers:(void(^)(NSArray <PhoneContact *> *contacts, NSError *error))completion;

/**
 Utility method used to partition the given objects in a way that's suitable to display in a table view containing section indexes

 @param array - array of PhoneContact objects to be partitioned
 @return returns a partitioned array
 */
+ (NSArray <NSArray *> *)partitionObjects:(NSArray <PhoneContact *> *)array;

@end
