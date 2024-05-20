//
//  JoinAlarmRequest.m
//  Safelet
//
//  Created by Alex Motoc on 04/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "JoinAlarmRequest.h"

@interface JoinAlarmRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) NSString *alarmObjectId;
@end

@implementation JoinAlarmRequest

+ (instancetype)requestWithUserObjectId:(NSString *)userObjId
                          alarmObjectId:(NSString *)alarmObjId {
    JoinAlarmRequest *request = [self request];
    
    request.userObjectId = userObjId;
    request.alarmObjectId = alarmObjId;
    
    return request;
}

- (NSString *)requestURL {
    return @"joinAlarm";
}

- (NSDictionary *)params {
    return @{@"alarmObjectId":self.alarmObjectId,
             @"aUserObjectId":self.userObjectId};
}

@end
