//
//  SendInvitationRequest.m
//  Safelet
//
//  Created by Alex Motoc on 20/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "SendGuardianInvitationRequest.h"

@interface SendGuardianInvitationRequest ()
@property (strong, nonatomic) NSString *fromUser;
@property (strong, nonatomic) NSString *toUser;
@end

@implementation SendGuardianInvitationRequest

+ (instancetype)requestWithFromUserObjectId:(NSString *)fromUser
                             toUserObjectId:(NSString *)toUser {
    SendGuardianInvitationRequest *request = [self request];
    
    request.fromUser = fromUser;
    request.toUser = toUser;
    
    return request;
}

- (NSString *)requestURL {
    return @"sendGuardianRequest";
}

- (NSDictionary *)params {
    return @{@"fromUser":self.fromUser, @"toUser":self.toUser};
}

@end
