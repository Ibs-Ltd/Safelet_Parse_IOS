//
//  UserToUserInvitationStatus.m
//
//  Created by Alex Motoc.
//  Copyright (c) 2014 Alex Motoc. All rights reserved.
//

#import "UserToUserInvitationStatus.h"

@implementation UserToUserInvitationStatus 

+ (instancetype)createWithUserStatus:(NSString *)userStatus otherStatus:(NSString *)otherStatus {
    UserToUserInvitationStatus *userToUserInvitationStatus = [self new];
    
    userToUserInvitationStatus.userSentInvitationStatus = userStatus;
    userToUserInvitationStatus.otherUserSentInvitationStatus = otherStatus;
    
    return userToUserInvitationStatus;
}

+ (instancetype)createFromDictionary:(NSDictionary *)dictionary {
    UserToUserInvitationStatus *userToUserInvitationStatus = [self new];
    
	userToUserInvitationStatus.userSentInvitationStatus = dictionary[@"userSentInvitationStatus"];
	userToUserInvitationStatus.otherUserSentInvitationStatus = dictionary[@"otherUserSentInvitationStatus"];
	
    return userToUserInvitationStatus;
}

- (NSDictionary *)toDictionary {
    NSDictionary *dictionary = @{
								@"userSentInvitationStatus":self.userSentInvitationStatus,
								@"otherUserSentInvitationStatus":self.otherUserSentInvitationStatus
                               };
    
    return dictionary;
}

+ (NSArray *)userToUserInvitationStatusesArrayFromDictionaryArray:(NSArray *)dictionaryArray {
	NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaryArray) {
        [array addObject:[UserToUserInvitationStatus createFromDictionary:dictionary]];
    }
    
    return array;
}

+ (NSArray *)dictionaryArrayFromUserToUserInvitationStatusesArray:(NSArray *)UserToUserInvitationStatusesArray {
	NSMutableArray *array = [NSMutableArray array];
    
    for (UserToUserInvitationStatus *userToUserInvitationStatus in UserToUserInvitationStatusesArray) {
        [array addObject:[userToUserInvitationStatus toDictionary]];
    }
    
    return array;
}

@end
