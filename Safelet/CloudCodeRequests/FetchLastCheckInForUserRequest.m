//
//  FetchLastCheckInForUserRequest.m
//  Safelet
//
//  Created by Alex Motoc on 28/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "FetchLastCheckInForUserRequest.h"

@interface FetchLastCheckInForUserRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@end

@implementation FetchLastCheckInForUserRequest

+ (instancetype)requestWithUserObjectId:(NSString *)userObjId {
    FetchLastCheckInForUserRequest *request = [self request];
    
    request.userObjectId = userObjId;
    
    return request;
}

- (NSString *)requestURL {
    return @"fetchLastCheckInForUser";
}

- (NSDictionary *)params {
    return @{@"aUserObjectId":self.userObjectId};
}

@end
