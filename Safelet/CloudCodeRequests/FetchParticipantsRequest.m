//
//  FetchParticipantsRequest.m
//  Safelet
//
//  Created by Alex Motoc on 05/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "FetchParticipantsRequest.h"

@interface FetchParticipantsRequest ()
@property (strong, nonatomic) NSString *alarmObjectId;
@end

@implementation FetchParticipantsRequest

+ (instancetype)requestWithAlarmObjectId:(NSString *)alarmObjId {
    FetchParticipantsRequest *request = [self request];
    
    request.alarmObjectId = alarmObjId;
    
    return request;
}

- (NSString *)requestURL {
    return @"fetchParticipantsForAlarm";
}

- (NSDictionary *)params {
    return @{@"alarmObjectId":self.alarmObjectId};
}

@end
