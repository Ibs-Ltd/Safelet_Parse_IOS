//
//  Alarm.h
//  Safelet
//
//  Created by Alex Motoc on 02/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "User.h"
#import "StopAlarmReason.h"
#import <Parse/Parse.h>

@interface Alarm : PFObject <PFSubclassing>

@property (strong, nonatomic) User *user; // the user that dispatched the alarm
@property (strong, nonatomic) StopAlarmReason *stopAlarmReason;
@property (strong, nonatomic, readonly) PFRelation *participants; // the users that are "on their way" (attending)
@property (nonatomic) BOOL isActive; // YES if the alarm is still active
@property (nonatomic) BOOL canRecord;
@property (nonatomic) NSInteger recordingChunksCount;

- (BOOL)isHistoric;
+ (NSString *)parseClassName;

@end
