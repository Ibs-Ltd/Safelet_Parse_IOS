//
//  GetFollowUserLocationRequest.m
//  Safelet
//
//  Created by Ram on 02/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "GetFollowUserLocationRequest.h"

@interface GetFollowUserLocationRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) NSString *followMeObjectId;

@end

@implementation GetFollowUserLocationRequest

+ (instancetype)getFollowUserLocation:(NSString *)objectId
                     followMeObjectId:(NSString *)followMeObjectId{
    
    GetFollowUserLocationRequest *request = [self request];
    
    request.userObjectId = objectId;
    request.followMeObjectId = followMeObjectId;
    
    return request;
}

- (NSString *)requestURL {
    return @"getFollowUserLocation";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"aObjectId":self.followMeObjectId
             };
}

@end
