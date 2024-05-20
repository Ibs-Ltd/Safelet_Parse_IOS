//
//  UserToUserInvitationStatus.h
//
//  Created by Alex Motoc.
//  Copyright (c) 2014 Alex Motoc. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Object that maps the relation between the current user and some other parse user.
 Used in FetchRelationStatusBetweenUserAndUsers request to create the response dictionary.
 An instance of this object doesn't mean anything if it's not used in context as a value object
 in a dictionary having as key the objectId of the other user involved in the relation (the dictionary created
 in FetchRelationStatusBetweenUserAndUsers)
 */
@interface UserToUserInvitationStatus : NSObject

// the status of the invitation initiated by the current user
@property (strong, nonatomic) NSString *userSentInvitationStatus;
// the status of the invitation initiated by the other user
@property (strong, nonatomic) NSString *otherUserSentInvitationStatus;

+ (instancetype)createWithUserStatus:(NSString *)userStatus otherStatus:(NSString *)otherStatus;
+ (instancetype)createFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;
+ (NSArray *)userToUserInvitationStatusesArrayFromDictionaryArray:(NSArray *)dictionaryArray;
+ (NSArray *)dictionaryArrayFromUserToUserInvitationStatusesArray:(NSArray *)UserToUserInvitationStatusesArray;

@end
