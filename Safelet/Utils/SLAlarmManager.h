//
//  AlarmManager.h
//  Safelet
//
//  Created by Alex Motoc on 30/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "Alarm.h"
#import <Foundation/Foundation.h>

/**
 *	Manager used to store the active alarm object dispatched by the current user and also handle
 *  the dispatching and stopping of alarms.
 *
 *  When dispatching an alarm, the app will enter Alarm Mode: more frequent location updates; red nav bar
 *  When stopping an alarm, the app will exit Alarm Mode: location updates normal (significant location); green nav bar
 */

@interface SLAlarmManager : NSObject

@property (strong, nonatomic) Alarm * _Nullable alarm;

/**
 *	Singleton constructor
 *
 *	@return singleton instance of this object
 */
+ (instancetype _Nonnull)sharedManager;

/**
 *	Runs a network request to fetch the active alarm dispatched by a given user.
 *
 *	@param user				the user for which we're searching an active alarm
 *	@param completion       void completion block called when this operation is finished
 */
+ (void)getAlarmForUser:(User * _Nonnull)user
             completion:(void(^ _Nullable)(Alarm * _Nullable alarm, NSError * _Nullable error))completion;

/**
 *	Handles the event of stopping the active alarm for the current user.
 *  This means exiting the Alarm Mode: make normal location updates (significant changes) + set green nav bar
 */
+ (void)handleStopAlarm;

/**
 *	Handles the event of stopping the active alarm for the current user.
 *  This means setting up the Alarm Mode: make location updates more frequently + set red nav bar
 *
 *	@param alarm	the alarm that has been dispatched
 */
+ (void)handleDispatchAlarm:(Alarm * _Nonnull)alarm shouldPlaySound:(BOOL)playSound;

@end
