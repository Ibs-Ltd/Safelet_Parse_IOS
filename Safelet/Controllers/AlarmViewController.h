//
//  AlarmViewController.h
//  Safelet
//
//  Created by Mihai Eros on 10/1/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BannerEnabledViewController.h"
#import <UIKit/UIKit.h>

@class Alarm;
@interface AlarmViewController : BannerEnabledViewController

NS_ASSUME_NONNULL_BEGIN
@property (strong, nonatomic, readonly) Alarm *alarm;

/**
 *	View controller constructor. Uses storyboard to initialize the view controller
 *
 *	@param alarm			the alarm object to populate the vc
 *
 *	@return vc instance
 */
+ (instancetype _Nonnull)createWithAlarm:(Alarm *)alarm;

- (void)handleUserJoinAlarmAction:(void(^)(BOOL success))completion;
- (void)handleUserCallEmergencyAction;
- (void)handleUserPlayAlarmAction:(void(^)(BOOL isPlaying))stateChangedBlock;
- (void)callCoder;
NS_ASSUME_NONNULL_END

@end
