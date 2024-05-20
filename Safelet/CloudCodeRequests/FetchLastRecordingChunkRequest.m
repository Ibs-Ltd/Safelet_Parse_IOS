//
//  FetchLastRecordingChunkRequest.m
//  Safelet
//
//  Created by Alex Motoc on 25/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "FetchLastRecordingChunkRequest.h"

@interface FetchLastRecordingChunkRequest ()
@property (strong, nonatomic) NSString *alarmObjectId;
@end

@implementation FetchLastRecordingChunkRequest

+ (instancetype)requestWithAlarmObjectId:(NSString *)alarmObjId {
    FetchLastRecordingChunkRequest *request = [self request];
    
    request.alarmObjectId = alarmObjId;
    
    return request;
}

- (NSString *)requestURL {
    return @"fetchLastRecordingChunkForAlarm";
}

- (NSDictionary *)params {
    return @{@"alarmObjectId":self.alarmObjectId};
}

@end
