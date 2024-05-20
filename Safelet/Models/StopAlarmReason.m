//
//  StopAlarmReason.m
//  Safelet
//
//  Created by Alex Motoc on 06/01/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "StopAlarmReason.h"
#import <Parse/PFObject+Subclass.h>

static NSString * const kParseClassName = @"StopAlarmReason";
static NSString * const kStopReasonTestAlarm = @"testAlarm";
static NSString * const kStopReasonAccidentalAlarm = @"accidentalAlarm";
static NSString * const kStopReasonHelpNoLongerNeeded = @"alarmNotNeeded";
static NSString * const kStopReasonOther = @"other";

@interface StopAlarmReason ()
@property (strong, nonatomic) NSString *reason;
@end

@implementation StopAlarmReason

@dynamic otherReasonDescription;
@dynamic reason;

#pragma mark - PFSubclassing

+ (NSString *)parseClassName {
    return kParseClassName;
}

+ (void)load {
    [self registerSubclass];
}

#pragma mark - logic

- (void)setStopReason:(StopReason)reason {
    switch (reason) {
        case StopReasonTestAlarm:
            self.reason = kStopReasonTestAlarm;
            break;
        case StopReasonAccidentalAlarm:
            self.reason = kStopReasonAccidentalAlarm;
            break;
        case StopReasonHelpNoLongerNeeded:
            self.reason = kStopReasonHelpNoLongerNeeded;
            break;
        case StopReasonOther:
            self.reason = kStopReasonOther;
            break;
        default:
            break;
    }
}

- (StopReason)selectedStopReason {
    if ([self.reason isEqualToString:kStopReasonTestAlarm]) {
        return StopReasonTestAlarm;
    } else if ([self.reason isEqualToString:kStopReasonAccidentalAlarm]) {
        return StopReasonAccidentalAlarm;
    } else if ([self.reason isEqualToString:kStopReasonHelpNoLongerNeeded]) {
        return StopReasonHelpNoLongerNeeded;
    } else {
        return StopReasonOther;
    }
}

+ (NSString *)stringForReason:(StopReason)reason {
    switch (reason) {
        case StopReasonTestAlarm:
            return kStopReasonTestAlarm;
        case StopReasonAccidentalAlarm:
            return kStopReasonAccidentalAlarm;
        case StopReasonHelpNoLongerNeeded:
            return kStopReasonHelpNoLongerNeeded;
        case StopReasonOther:
            return kStopReasonOther;
        default:
            return @"";
    }
}

@end
