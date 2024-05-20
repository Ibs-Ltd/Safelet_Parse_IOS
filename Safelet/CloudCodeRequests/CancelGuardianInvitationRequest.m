//
//  CancelGuardianInvitationRequest.m
//  Safelet
//
//  Created by Alex Motoc on 20/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CancelGuardianInvitationRequest.h"

@interface CancelGuardianInvitationRequest ()
@property (strong, nonatomic) NSString *fromUser;
@property (strong, nonatomic) NSString *toUser;
@end

@implementation CancelGuardianInvitationRequest

+ (instancetype)requestWithFromUserObjectId:(NSString *)fromUser
                             toUserObjectId:(NSString *)toUser {
    CancelGuardianInvitationRequest *request = [self request];
    
    request.fromUser = fromUser;
    request.toUser = toUser;
    
    return request;
}

- (NSString *)requestURL {
    return @"cancelGuardianInvitation";
}

- (NSDictionary *)params {
    return @{@"fromUser":self.fromUser, @"toUser":self.toUser};
}

@end
