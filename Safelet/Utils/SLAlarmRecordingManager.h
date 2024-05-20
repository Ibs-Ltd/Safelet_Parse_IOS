//
//  SLAlarmRecordingManager.h
//  Safelet
//
//  Created by Alex Motoc on 07/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SLAlarmRecordingManager;
@protocol SLAlarmRecordingDelegate <NSObject>

- (void)recordingMangerDidStartRecording:(SLAlarmRecordingManager *)manager;
- (void)recordingMangerDidStopRecording:(SLAlarmRecordingManager *)manager;

@end

@interface SLAlarmRecordingManager : NSObject

@property (weak, nonatomic) id <SLAlarmRecordingDelegate> delegate;
@property (nonatomic) BOOL isRecording;

+ (instancetype _Nonnull)sharedManager;

/**
 *  Starts recording chunks for the given Alarm object.
 *  Uploads to server the chunks and associates them with the given Alarm object
 */
- (void)startRecording:(Alarm *)alarm;
- (void)stopRecording;

@end

NS_ASSUME_NONNULL_END