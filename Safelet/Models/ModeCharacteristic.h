//
//  ModeCharacteristic.h
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseCharacteristic.h"

typedef NS_ENUM(NSInteger, SafeletUnitMode) {
    SafeletUnitModeSleeping = 0, // main mode;
    SafeletUnitModeTest = 1, // test mode for maintenance
    SafeletUnitModeConnectedEmergency = 2, // when the phone is connected and both buttons are pressed on the Safelet
    SafeletUnitModeDisconnectedEmergency = 3, // when the phone is NOT connected and both buttons are pressed on the Safelet
    SafeletUnitModeCancelEmergency = 4, // must be set in this mode in order for it to go back into Sleeptig mode (happens automatically)
    SafeletUnitModeImageUPD = 5, // when firmware update is happening
    SafeletUnitModeReset = 6, // when resetting
};

@interface ModeCharacteristic : BaseCharacteristic

/**
 *  Reads the characteristic value and interprets it into a SafeletUnitMode value
 *
 *  @param completion completion block
 */
- (void)readCurrentMode:(void(^)(SafeletUnitMode mode, NSError *error))completion;

- (void)setModeTo:(SafeletUnitMode)mode completion:(void(^)(NSError *error))completion;

+ (NSString *)convertToString:(SafeletUnitMode)mode;

@end
