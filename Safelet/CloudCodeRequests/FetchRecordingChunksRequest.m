//
//  FetchRecordingChunksRequest.m
//  Safelet
//
//  Created by Alex Motoc on 25/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "FetchRecordingChunksRequest.h"

@interface FetchRecordingChunksRequest ()
@property (strong, nonatomic) NSString *alarmObjectId;
@end

@implementation FetchRecordingChunksRequest

+ (instancetype)requestWithAlarmObjectId:(NSString *)alarmObjId {
    FetchRecordingChunksRequest *request = [self request];
    
    request.alarmObjectId = alarmObjId;
    
    return request;
}

- (NSString *)requestURL {
    return @"fetchAllRecordingChunksForAlarm";
}

- (NSDictionary *)params {
    return @{@"alarmObjectId":self.alarmObjectId};
}

@end
