//
//  AlarmManager.m
//  Safelet
//
//  Created by Alex Motoc on 30/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "SLAlarmManager.h"
#import "User+Requests.h"
#import "SLLocationManager.h"
#import "SLAlarmRecordingManager.h"
#import "SafeletUnitManager.h"
#import "SLAlarmPlaybackManager.h"

@implementation SLAlarmManager

+ (instancetype)sharedManager {
    static SLAlarmManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    
    return manager;
}

+ (void)getAlarmForUser:(User *)user completion:(void (^)(Alarm *alarm, NSError *error))completion {
    [user fetchActiveAlarmWithCompletion:^(Alarm * _Nullable alarm, NSError * _Nullable error) {
        if (completion) {
            completion(alarm, error);
        }
    }];
}

+ (void)handleStopAlarm {
    [[SLLocationManager sharedManager] setupNormalLocationTracking];
    
    if ([SLAlarmRecordingManager sharedManager].isRecording) {
        [[SLAlarmRecordingManager sharedManager] stopRecording];
    }
    
    // clear cached data lastly, because other managers are using it
    [SLAlarmManager sharedManager].alarm = nil;
    
    if ([SafeletUnitManager shared].safeletPeripheral.isConnected) {
        [[SafeletUnitManager shared] exitEmergencyModeForConnectedDevice:nil];
    }
}

+ (void)handleDispatchAlarm:(Alarm *)alarm shouldPlaySound:(BOOL)playSound {
    [SLAlarmManager sharedManager].alarm = alarm;
    [[SLLocationManager sharedManager] setupPreciseLocationTracking];
    
    if (playSound) {
//        this code causes the background recorder framework to crash; it's not removed because it should be fixed, such that a confirmation sound is played when an alarm is dispatched successfully
//        [[SLAlarmPlaybackManager sharedManager] playSuccessAlarmDispatchSound:^{
//            [[SLAlarmPlaybackManager sharedManager] stopPlayback];
        
            if (alarm.canRecord) {
                [[SLAlarmRecordingManager sharedManager] startRecording:alarm];
            }
//        }];
    } else if (alarm.canRecord) {
        [[SLAlarmRecordingManager sharedManager] startRecording:alarm];
    }
}

@end
