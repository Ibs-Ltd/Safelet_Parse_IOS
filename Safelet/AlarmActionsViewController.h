//
//  AlarmActionsViewController.h
//  Safelet
//
//  Created by Alexandru Motoc on 20/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlarmActionsViewController, Alarm, AlarmChatViewController;
@protocol AlarmActionsDelegate <NSObject>

- (void)alarmActionsControllerDidSelectPlayRecording:(AlarmActionsViewController *)controller;
- (void)alarmActionsControllerDidSelectJoinAlarm:(AlarmActionsViewController *)controller;
- (void)alarmActionsControllerDidSelectCallEmergency:(AlarmActionsViewController *)controller;
- (void)alarmActionsControllerDidSelectShowChat:(AlarmActionsViewController *)controller;

@end

@interface AlarmActionsViewController : UIViewController

@property (strong, nonatomic, readonly) Alarm *alarm;
@property (strong, nonatomic) AlarmChatViewController *chatViewController;
@property (nonatomic) BOOL joinAlarmButtonEnabled; // defaults to YES
@property (weak, nonatomic) id <AlarmActionsDelegate> actionsDelegate;
@property (nonatomic) CGFloat blurViewYPos; // where the blur view should start
@property (nonatomic) CGFloat collapsedHeight; // computed such that "Tap to chat" button is visible


+ (instancetype)createFromStoryboardWithAlarm:(Alarm *)alarm;
- (void)hideAlarmActionButtons;
- (void)disableJoinAlarmButton;
- (void)updatePlayAudioButton:(BOOL)isPlaying;

@end
