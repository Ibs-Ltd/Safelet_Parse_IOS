//
//  SLAlarmPlaybackManager.h
//  Safelet
//
//  Created by Alex Motoc on 23/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    unsigned minute;
    unsigned second;
    
    /**
     * Playback time in seconds.
     */
    float playbackTimeInSeconds;
    
    /**
     * Position within the stream, where 0 is the beginning
     * and 1.0 is the end.
     */
    float position;
} SLPlaybackPosition;

typedef NS_ENUM(NSInteger, SLAlarmPlaybackState) {
    SLAlarmPlaybackStateStartedSuccess,
    SLAlarmPlaybackStateFailed,
    SLAlarmPlaybackStateBuffering,
    SLAlarmPlaybackStatePlaying,
    SLAlarmPlaybackStateCompleted
};

@class AlarmRecordingChunk;
@interface SLAlarmPlaybackManager : NSObject

@property (nonatomic) BOOL isPlaying;

+ (instancetype _Nonnull)sharedManager;
/**
 *  Starts playback from the beginning
 */
- (void)startPlayback:(Alarm *)alarm stateChangedBlock:(void (^ _Nullable)(SLAlarmPlaybackState state))block;

/**
 *  Each time a new chunk is available, update the playlist with the chunk url
 *  If the provided chunk is the same as the one that is currently playing, don't add it
 *
 *  @param chunk the new chunk
 */
- (void)addChunkToPlayback:(AlarmRecordingChunk *)chunk;
- (void)stopPlayback;
- (void)playSuccessAlarmDispatchSound:(void (^ _Nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
