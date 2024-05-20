//
//  FetchListOfGuardedUsersRequest.m
//  Safelet
//
//  Created by Alex Motoc on 22/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "FetchListOfGuardedUsersRequest.h"

@interface FetchListOfGuardedUsersRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@end

@implementation FetchListOfGuardedUsersRequest

+ (instancetype)requestWithUserObjectId:(NSString *)userObjectId {
    FetchListOfGuardedUsersRequest *request = [self request];
    
    request.userObjectId = userObjectId;
    
    return request;
}

- (NSString *)requestURL {
    return @"fetchListOfUsersGuardedByUser";
}

- (NSDictionary *)params {
    return @{@"aUserObjectId":self.userObjectId};
}

@end
