//
//  RemoveGuardianRequest.m
//  Safelet
//
//  Created by Alex Motoc on 20/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "RemoveGuardianRequest.h"

@interface RemoveGuardianRequest ()
@property (strong, nonatomic) NSString *fromUser;
@property (strong, nonatomic) NSString *toUser;
@property (strong, nonatomic) NSString *initiator;
@end

@implementation RemoveGuardianRequest

+ (instancetype)requestWithFromUserObjectId:(NSString *)fromUser
                             toUserObjectId:(NSString *)toUser
                      initiatorUserObjectId:(NSString *)initiator {
    RemoveGuardianRequest *request = [self request];
    
    request.fromUser = fromUser;
    request.toUser = toUser;
    request.initiator = initiator;
    
    return request;
}

- (NSString *)requestURL {
    return @"removeGuardianConnection";
}

- (NSDictionary *)params {
    return @{@"fromUser":self.fromUser,
             @"toUser":self.toUser,
             @"initiatingUserObjectId":self.initiator};
}

@end
