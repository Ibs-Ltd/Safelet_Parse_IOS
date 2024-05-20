//
//  BackgroundRecorder.h
//  bgrec
//
//  Created by Gordon Childs on 11/02/2017.
//  Copyright © 2017 Gordon Childs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^BackgroundRecorderCallback)(NSURL *fileUrl, NSError *error);

@interface BackgroundRecorder : NSObject

- (BOOL)startRecording:(BackgroundRecorderCallback)callback;

- (void)stopRecording;

@end
