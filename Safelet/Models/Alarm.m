//
//  Alarm.m
//  Safelet
//
//  Created by Alex Motoc on 02/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "Alarm.h"
#import <Parse/PFObject+Subclass.h>

static NSString * const kParseClassName = @"Alarm";

@implementation Alarm

@dynamic user;
@dynamic participants;
@dynamic isActive;
@dynamic canRecord;
@dynamic recordingChunksCount;
@dynamic stopAlarmReason;

- (BOOL)isHistoric {
    return self.isActive == NO;
}

#pragma mark - PFSubclassing

+ (NSString *)parseClassName {
    return kParseClassName;
}

+ (void)load {
    [self registerSubclass];
}

@end
