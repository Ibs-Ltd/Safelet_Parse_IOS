//
//  FetchActiveAlarmRequest.m
//  Safelet
//
//  Created by Alex Motoc on 29/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "FetchActiveAlarmRequest.h"

@interface FetchActiveAlarmRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@end

@implementation FetchActiveAlarmRequest

+ (instancetype)requestWithUserObjectId:(NSString *)objectId {
    FetchActiveAlarmRequest *request = [self request];
    
    request.userObjectId = objectId;
    
    return request;
}

- (NSString *)requestURL {
    return @"fetchActiveAlarmForUser";
}

- (NSDictionary *)params {
    return @{@"aUserObjectId":self.userObjectId};
}

@end
