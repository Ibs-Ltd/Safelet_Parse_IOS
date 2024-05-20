//
//  StopAlarmReason.h
//  Safelet
//
//  Created by Alex Motoc on 06/01/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef NS_ENUM(NSUInteger, StopReason) {
    StopReasonTestAlarm,
    StopReasonAccidentalAlarm,
    StopReasonHelpNoLongerNeeded,
    StopReasonOther
};

@interface StopAlarmReason : PFObject <PFSubclassing>

@property (strong, nonatomic, readonly) NSString *reason;
@property (strong, nonatomic) NSString *otherReasonDescription;

- (void)setStopReason:(StopReason)reason;
- (StopReason)selectedStopReason;
+ (NSString *)stringForReason:(StopReason)reason;

@end
