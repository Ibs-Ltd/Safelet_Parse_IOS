//
//  StopFollowUserRequest.m
//  Safelet
//
//  Created by Ram on 02/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "StopFollowUserRequest.h"

@interface StopFollowUserRequest ()

@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) NSString *followMeObjectId;

@end

@implementation StopFollowUserRequest

+ (instancetype)stopFollowUser:(NSString *)objectId
              followMeObjectId:(NSString *)followMeObjectId{
    
    StopFollowUserRequest *request = [self request];
    
    request.userObjectId = objectId;
    request.followMeObjectId = followMeObjectId;
    
    return request;
}

- (NSString *)requestURL {
    return @"stopFollowUser";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"aObjectId":self.followMeObjectId
             };
}

@end
