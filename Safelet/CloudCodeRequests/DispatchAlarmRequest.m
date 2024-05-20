//
//  DispatchAlarmRequest.m
//  Safelet
//
//  Created by Alex Motoc on 29/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "DispatchAlarmRequest.h"

@interface DispatchAlarmRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@end

@implementation DispatchAlarmRequest

+ (instancetype)requestWithUserObjectId:(NSString *)objectId {
    DispatchAlarmRequest *request = [self request];
    
    request.userObjectId = objectId;
    
    return request;
}

- (NSString *)requestURL {
    return @"dispatchAlarmForUser";
}

- (NSDictionary *)params {
    return @{@"aUserObjectId":self.userObjectId};
}

@end
