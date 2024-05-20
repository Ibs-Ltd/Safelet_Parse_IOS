//
//  AlarmRecordingChunk.h
//  Safelet
//
//  Created by Alex Motoc on 21/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "Alarm.h"
#import <Parse/Parse.h>

@interface AlarmRecordingChunk : PFObject <PFSubclassing>

@property (strong, nonatomic) PFFileObject *chunkFile;
@property (strong, nonatomic) Alarm *alarm;

@end
