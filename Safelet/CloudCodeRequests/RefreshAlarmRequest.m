//
//  RefreshAlarmRequest.m
//  Safelet
//
//  Created by Alex Motoc on 25/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "RefreshAlarmRequest.h"

@interface RefreshAlarmRequest ()
@property (strong, nonatomic) NSString *alarmObjectId;
@end

@implementation RefreshAlarmRequest

+ (instancetype)requestWithAlarmObjectId:(NSString *)alarmObjId {
    RefreshAlarmRequest *request = [self request];
    
    request.alarmObjectId = alarmObjId;
    
    return request;
}

- (NSString *)requestURL {
    return @"refreshAlarmData";
}

- (NSDictionary *)params {
    return @{@"alarmObjectId":self.alarmObjectId};
}

@end
