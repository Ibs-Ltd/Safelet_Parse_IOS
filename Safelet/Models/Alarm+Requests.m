//
//  Alarm+Requests.m
//  Safelet
//
//  Created by Alex Motoc on 03/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "Alarm+Requests.h"
#import "User+Requests.h"
#import "StopAlarmRequest.h"
#import "FetchParticipantsRequest.h"
#import "RefreshAlarmRequest.h"
#import "FetchRecordingChunksRequest.h"
#import "FetchLastRecordingChunkRequest.h"
#import "NotifyParticipantsWhenCalledEmergency.h"

@implementation Alarm (Requests)

- (void)stopWithReason:(StopReason)reason reasonDescription:(NSString *)reasonDescription completion:(void (^)(BOOL, NSError * _Nullable))completion {
    StopAlarmRequest *request = [StopAlarmRequest requestWithAlarmObjectId:self.objectId stopReason:reason reasonDescription:reasonDescription];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}

- (void)fetchParticipantsWithProgressIndicator:(BOOL)showProgress
                                    completion:(void (^)(NSArray<User *> * _Nullable, NSError * _Nullable))completion {
    FetchParticipantsRequest *request = [FetchParticipantsRequest requestWithAlarmObjectId:self.objectId];
    
    request.showsProgressIndicator = showProgress;
    [request setRequestCompletionBlock:^(NSArray <User *> * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}

- (void)checkIfUserIsParticipant:(User *)user completion:(void (^)(BOOL, NSError * _Nullable error))completion {
    [self fetchParticipantsWithProgressIndicator:YES
                                      completion:^(NSArray<User *> * _Nullable participants, NSError * _Nullable error) {
                                          if (completion) { // if user is in participants array, he's a participant
                                              completion([participants containsObject:user], error);
                                          }
                                      }];
}

- (void)refreshAlarmDataInBackgroundWithCompletion:(void (^)(Alarm * _Nullable alarm, NSError * _Nullable error))completion {
    RefreshAlarmRequest *request = [RefreshAlarmRequest requestWithAlarmObjectId:self.objectId];
    
    request.showsProgressIndicator = NO;
    [request setRequestCompletionBlock:^(Alarm * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}

- (void)fetchRecordingChunksWithCompletion:(void (^)(NSArray<AlarmRecordingChunk *> * _Nullable chunks, NSError * _Nullable error))completion {
    FetchRecordingChunksRequest *request = [FetchRecordingChunksRequest requestWithAlarmObjectId:self.objectId];
    
    [request setRequestCompletionBlock:^(NSArray<AlarmRecordingChunk *> * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}

- (void)fetchLastRecordingChunkWithCompletion:(void (^)(AlarmRecordingChunk * _Nullable chunk, NSError * _Nullable error))completion {
    FetchLastRecordingChunkRequest *request = [FetchLastRecordingChunkRequest requestWithAlarmObjectId:self.objectId];
    
    request.showsProgressIndicator = NO;
    [request setRequestCompletionBlock:^(AlarmRecordingChunk * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}

- (void)notifyParticipantsCurrentUserCalledEmergency:(void (^)(BOOL success, NSError * _Nullable error))completion {
    NotifyParticipantsWhenCalledEmergency *request = [NotifyParticipantsWhenCalledEmergency requestWithAlarmObjectId:self.objectId];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}

@end
