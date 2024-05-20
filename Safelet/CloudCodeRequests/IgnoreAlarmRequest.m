//
//  IgnoreAlarmRequest.m
//  Safelet
//
//  Created by Alex Motoc on 27/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "IgnoreAlarmRequest.h"

@interface IgnoreAlarmRequest ()
@property (strong, nonatomic) NSString *alarmObjectId;
@end

@implementation IgnoreAlarmRequest

+ (instancetype)requestWithAlarmObjectId:(NSString *)alarmObjId {
    IgnoreAlarmRequest *request = [self request];
    
    request.alarmObjectId = alarmObjId;
    
    return request;
}

- (NSString *)requestURL {
    return @"ignoreAlarm";
}

- (NSDictionary *)params {
    return @{@"alarmObjectId":self.alarmObjectId};
}

@end
