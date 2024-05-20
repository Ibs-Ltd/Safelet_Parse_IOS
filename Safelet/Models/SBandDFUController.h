//
//  SBandDFUController.h
//  Safelet
//
//  Created by Alexandru Motoc on 18/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "Firmware.h"
#import "BlockTypes.h"
#import "SafeletUnit.h"
#import <Foundation/Foundation.h>
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface SBandDFUController : NSObject <DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate>

+ (instancetype)shared;
- (void)updateSBand:(SafeletUnit *)safelet
           firmware:(Firmware *)firmware
           progress:(FirmwareProgress)progressBlock
         completion:(void(^)(NSError *error))completion;

@end
