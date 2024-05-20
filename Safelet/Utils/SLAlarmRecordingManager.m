//
//  SLAlarmRecordingManager.m
//  Safelet
//
//  Created by Alex Motoc on 07/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "Alarm+Requests.h"
#import "AlarmRecordingChunk.h"
#import "SLAlarmRecordingManager.h"
#import "Utils.h"
#import "SLErrorHandlingController.h"
#import <AVFoundation/AVFoundation.h>
//#import "BackgroundRecorder.h"
#import <BackgroundRecorder/BackgroundRecorder.h>

@interface SLAlarmRecordingManager ()
@property (strong, nonatomic) Alarm *alarm;
@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) BackgroundRecorder *bgRec;
@end

@implementation SLAlarmRecordingManager

+ (instancetype)sharedManager {
    static SLAlarmRecordingManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
        manager.bgRec = [BackgroundRecorder new];
    });
    
    return manager;
}

#pragma mark - Logic

- (void)startRecording:(Alarm *)alarm {
    self.isRecording = YES;
    self.alarm = alarm;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bgRec startRecording:^(NSURL *fileUrl, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSLog(@"ERROR CHUNK: %@", error);
                    return;
                }
                
                NSError *err = nil;
                NSData *data = [NSData dataWithContentsOfURL:fileUrl options:NSDataReadingUncached error:&err];
                if (err) {
                    NSLog(@"ERROR READ FILE FROM URL: %@", error);
                    return;
                }
                
                NSLog(@"Data length: %ld", (long)data.length);
                
                if (data.length > 0) {
                    [self saveToServerAudioFileData:data];
                }
            });
        }];
    });
    
    if ([self.delegate respondsToSelector:@selector(recordingMangerDidStartRecording:)]) {
        [self.delegate recordingMangerDidStartRecording:self];
    }
}

- (void)stopRecording {
    self.isRecording = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bgRec stopRecording];
    });
    
    if ([self.delegate respondsToSelector:@selector(recordingMangerDidStopRecording:)]) {
        [self.delegate recordingMangerDidStopRecording:self];
    }
    
    self.startDate = nil;
    self.alarm = nil;
}

#pragma mark - Utils

- (void)saveToServerAudioFileData:(NSData *)audioFileData {
    NSString *fileName = @"sound.aac";
    
    AlarmRecordingChunk *chunk = [AlarmRecordingChunk object];
    chunk.alarm = self.alarm;
//    chunk.chunkFile = [PFFile fileWithName:fileName data:audioFileData];
    chunk.chunkFile = [PFFileObject fileObjectWithName:fileName data:audioFileData];
    
    [chunk saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            [self.alarm fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable err) {
                if (self.alarm.canRecord == NO && self.isRecording) {
                    [SLErrorHandlingController handleError:error];

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.bgRec stopRecording];
                    });
                    
                    self.startDate = nil;
                    self.alarm = nil;
                    self.isRecording = NO;
                    
                    if ([self.delegate respondsToSelector:@selector(recordingMangerDidStopRecording:)]) {
                        [self.delegate recordingMangerDidStopRecording:self];
                    }
                }
            }];
        }
    }];
}

@end
