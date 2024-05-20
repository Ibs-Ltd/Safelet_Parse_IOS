//
//  AlarmRecordingChunk.m
//  Safelet
//
//  Created by Alex Motoc on 21/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "AlarmRecordingChunk.h"
#import <Parse/PFObject+Subclass.h>

static NSString * const kParseClassName = @"AlarmRecordingChunk";

@implementation AlarmRecordingChunk

@dynamic alarm;
@dynamic chunkFile;

#pragma mark - PFSubclassing

+ (NSString *)parseClassName {
    return kParseClassName;
}

+ (void)load {
    [self registerSubclass];
}

@end
