//
//  NotifyParticipantsWhenCalledEmergency.m
//  Safelet
//
//  Created by Alex Motoc on 31/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "NotifyParticipantsWhenCalledEmergency.h"

@interface NotifyParticipantsWhenCalledEmergency ()
@property (strong, nonatomic) NSString *alarmObjectId;
@end

@implementation NotifyParticipantsWhenCalledEmergency

+ (instancetype)requestWithAlarmObjectId:(NSString *)alarmObjId {
    NotifyParticipantsWhenCalledEmergency *request = [self request];
    
    request.alarmObjectId = alarmObjId;
    
    return request;
}

- (NSString *)requestURL {
    return @"notifyParticipantsDidCallEmergency";
}

- (NSDictionary *)params {
    return @{@"alarmObjectId":self.alarmObjectId};
}

@end
