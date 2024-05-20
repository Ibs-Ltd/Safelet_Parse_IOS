//
//  FetchListOfGuardianUsersRequest.m
//  Safelet
//
//  Created by Alex Motoc on 22/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "FetchListOfGuardianUsersRequest.h"

@interface FetchListOfGuardianUsersRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@end

@implementation FetchListOfGuardianUsersRequest

+ (instancetype)requestWithUserObjectId:(NSString *)userObjectId {
    FetchListOfGuardianUsersRequest *request = [self request];
    
    request.userObjectId = userObjectId;
    
    return request;
}

- (NSString *)requestURL {
    return @"fetchListOfGuardiansForUser";
}

- (NSDictionary *)params {
    return @{@"aUserObjectId":self.userObjectId};
}

@end
