//
//  StopAlarmRequest.m
//  Safelet
//
//  Created by Alex Motoc on 04/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "StopAlarmRequest.h"

@interface StopAlarmRequest ()
@property (strong, nonatomic) NSString *alarmObjectId;
@property (strong, nonatomic) NSString *stopReasonDescription;
@property (nonatomic) StopReason stopReason;
@end

@implementation StopAlarmRequest

+ (instancetype)requestWithAlarmObjectId:(NSString *)alarmObjId
                              stopReason:(StopReason)reason
                       reasonDescription:(NSString * _Nullable)reasonDescription {
    StopAlarmRequest *request = [self request];
    
    request.alarmObjectId = alarmObjId;
    request.stopReason = reason;
    request.stopReasonDescription = reasonDescription;
    
    return request;
}

- (NSString *)requestURL {
    return @"stopAlarm";
}

- (NSDictionary *)params {
    return @{
             @"alarmObjectId":self.alarmObjectId,
             @"stopAlarmReason":[StopAlarmReason stringForReason:self.stopReason],
             @"stopReasonDescription":self.stopReasonDescription ?: @""
             };
}

@end
