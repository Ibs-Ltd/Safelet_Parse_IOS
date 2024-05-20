//
//  StopFollowMeRequest.m
//  Safelet
//
//  Created by Ram on 02/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "StopFollowMeRequest.h"

@interface StopFollowMeRequest ()

@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) NSString *followMeObjectId;

@end

@implementation StopFollowMeRequest

+ (instancetype)stopFollowMe:(NSString *)objectId
            followMeObjectId:(NSString *)followMeObjectId{
    
    StopFollowMeRequest *request = [self request];
    
    request.userObjectId = objectId;
    request.followMeObjectId = followMeObjectId;
    
    return request;
}

- (NSString *)requestURL {
    return @"stopFollowMe";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"aObjectId":self.followMeObjectId
             };
}

@end
