//
//  SLAlarmPlaybackManager.m
//  Safelet
//
//  Created by Alex Motoc on 23/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "Alarm.h"
#import "AlarmRecordingChunk.h"
#import "SLAlarmPlaybackManager.h"
#import "Alarm+Requests.h"
#import "SLErrorHandlingController.h"
#import "Utils.h"
#import <FreeStreamer/FSPlaylistItem.h>
#import <FreeStreamer/FSAudioController.h>

@interface SLAlarmPlaybackManager ()
@property (strong, nonatomic) FSAudioController *audioController;
@property (strong, nonatomic) AlarmRecordingChunk *latestChunk;
@property (nonatomic) NSInteger playedChunks;
@end

@implementation SLAlarmPlaybackManager

+ (instancetype)sharedManager {
    static SLAlarmPlaybackManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    
    return manager;
}

- (void)startPlayback:(Alarm *)alarm stateChangedBlock:(void (^ _Nullable)(SLAlarmPlaybackState))block {
    self.playedChunks = 0;
    [alarm fetchRecordingChunksWithCompletion:^(NSArray<AlarmRecordingChunk *> * _Nullable chunks, NSError * _Nullable error) {
        self.audioController = [FSAudioController new];
        self.audioController.configuration.requireStrictContentTypeChecking = NO;
        
        if (chunks && chunks.count > 0) {
            self.latestChunk = [chunks lastObject];
            
            NSMutableArray <FSPlaylistItem *> *playlist = [NSMutableArray array];
            for (AlarmRecordingChunk *chunk in chunks) {
                NSURL *url = [NSURL URLWithString:chunk.chunkFile.url];
                
                FSPlaylistItem *item = [FSPlaylistItem new];
                item.originatingUrl = url;
                item.url = url;
                
                if (item.url != nil) {
                    [playlist addObject:item];
                }
            }
            
            self.isPlaying = YES;
            __weak typeof (self) weakSelf = self;
            
            [self.audioController setOnStateChange:^(FSAudioStreamState state) {
                switch (state) {
                    case kFsAudioStreamPlaybackCompleted:
                        ++weakSelf.playedChunks;
                        if (weakSelf.playedChunks == [weakSelf.audioController countOfItems]) {
                            block(SLAlarmPlaybackStateCompleted);
                            [weakSelf.audioController stop];
                        }
                    case kFsAudioStreamBuffering:
                        block(SLAlarmPlaybackStateBuffering);
                    case kFsAudioStreamPlaying:
                        block(SLAlarmPlaybackStatePlaying);
                    default:
                        break;
                }
            }];
            
            [self.audioController playFromPlaylist:playlist];
            
            if (block) {
                block(SLAlarmPlaybackStateStartedSuccess);
            }
        } else {
            if (error) {
                [SLErrorHandlingController handleError:error];
            } else {
                NSString *msg = NSLocalizedString(@"No recording available at the moment. Please try again later", nil);
                [UIAlertController showErrorAlertWithMessage:msg];
            }
            
            if (block) {
                block(SLAlarmPlaybackStateFailed);
            }
        }
    }];
}

- (void)addChunkToPlayback:(AlarmRecordingChunk *)chunk {
    if (self.latestChunk && [chunk.createdAt compare:self.latestChunk.createdAt] != NSOrderedDescending) {
        return;
    }
    
    self.latestChunk = chunk;
    NSURL *url = [NSURL URLWithString:chunk.chunkFile.url];
    
    FSPlaylistItem *item = [FSPlaylistItem new];
    item.originatingUrl = url;
    item.url = url;
    
    if (item.url == nil) {
        return;
    }
    
    if (self.audioController.isPlaying) {
        [self.audioController addItem:item];
    } else {
        [self.audioController playFromPlaylist:@[item]];
    }
}

- (void)stopPlayback {
    [self.audioController stop];
    self.audioController = nil;
    
    self.isPlaying = NO;
    self.audioController = nil;
    self.latestChunk = nil;
}

- (void)playSuccessAlarmDispatchSound:(void (^)(void))completion {
    self.audioController = [FSAudioController new];
    NSString *alarmAudio = [[NSBundle mainBundle] pathForResource:@"alarm_success_dispatch" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:alarmAudio];
    
    [self.audioController setOnStateChange:^(FSAudioStreamState state) {
        if (state == kFsAudioStreamPlaybackCompleted) {
            if (completion) {
                completion();
            }
        }
    }];
    
    [self.audioController playFromURL:url];
}

@end
