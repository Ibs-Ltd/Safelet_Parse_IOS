//
//  FirmwareUpdateCharacteristic.h
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseCharacteristic.h"

@interface FirmwareUpdateCharacteristic : BaseCharacteristic

// progress is between 0.0f and 1.0f
- (void)writeNewFirmwareData:(NSData *)data
                    progress:(void(^)(float progress))progress
                  completion:(void(^)(NSError *error))completion;

@end
