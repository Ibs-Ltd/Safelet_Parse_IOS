//
//  RespondToGuardianInvitationRequest.m
//  Safelet
//
//  Created by Alex Motoc on 20/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "RespondToGuardianInvitationRequest.h"

@interface RespondToGuardianInvitationRequest ()
@property (strong, nonatomic) NSString *fromUser;
@property (strong, nonatomic) NSString *toUser;
@property (nonatomic) SLGuardianInvitationResponseType responseType;
@end

@implementation RespondToGuardianInvitationRequest

+ (instancetype)requestWithFromUserObjectId:(NSString *)fromUser
                             toUserObjectId:(NSString *)toUser
                             responseStatus:(SLGuardianInvitationResponseType)responseType {
    RespondToGuardianInvitationRequest *request = [self request];
    
    request.fromUser = fromUser;
    request.toUser = toUser;
    request.responseType = responseType;
    
    return request;
}

- (NSString *)requestURL {
    return @"respondToGuardianInvitation";
}

- (NSDictionary *)params {
    // map the response type enum into the corresponding guardian invitation status string
    NSString *status = nil;
    if (self.responseType == SLGuardianInvitationResponseTypeAccepted) {
        status = kGuardianInvitationStatusAccepted;
    } else if (self.responseType == SLGuardianInvitationResponseTypeRejected) {
        status = kGuardianInvitationStatusRejected;
    }
    
    return @{@"fromUser":self.fromUser,
             @"toUser":self.toUser,
             @"status":status};
}

@end
