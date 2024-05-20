//
//  ModeCharacteristic.m
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "ModeCharacteristic.h"
#import "SLError.h"
#import "NSException+NSError.h"

static int64_t const kUUIDValueHi = 0xC0695A31FF1181A7;
static int64_t const kUUIDValueLo = 0x8441DBEE27470FD3;

@implementation ModeCharacteristic

+ (NSString *)characteristicName {
    return @"mode";
}

+ (yms_u128_t)characteristicUUID {
    yms_u128_t offset = {kUUIDValueHi, kUUIDValueLo};
    
    return offset;
}

- (void)readCurrentMode:(void (^)(SafeletUnitMode, NSError *))completion {
    [self readIntegerValue:^(NSInteger value, NSError *error) {
        if (completion) {
            completion(value, error);
        }
    }];
}

- (void)setModeTo:(SafeletUnitMode)mode completion:(void (^)(NSError *))completion {
    if (mode < 0 || mode > 6) {
        NSAssert(NO, @"Can't set ModeCharacteristic to value %ld. Supported values are 0 to 6 (see SafeletUnitMode)", (long)mode);
    } else {
        @try {
            [self writeByte:mode withBlock:^(NSError *error) {
                completion == nil ?: completion(error);
            }];
        } @catch (NSException *exception) {
            NSLog(@"BLUETOOTH - caught exception: %@", exception);
            completion == nil ?: completion([exception toError]);
        }
    }
}

+ (NSString *)convertToString:(SafeletUnitMode)mode {
    switch (mode) {
        case SafeletUnitModeSleeping:
            return NSLocalizedString(@"Sleeping", nil);
        case SafeletUnitModeDisconnectedEmergency:
            return NSLocalizedString(@"Disconnected Emergency", nil);
        case SafeletUnitModeConnectedEmergency:
            return NSLocalizedString(@"Connected Emergency", nil);
        case SafeletUnitModeCancelEmergency:
            return NSLocalizedString(@"Cancel Emergency", nil);
        case SafeletUnitModeTest:
            return NSLocalizedString(@"Test", nil);
        case SafeletUnitModeImageUPD:
            return NSLocalizedString(@"Firmware Update", nil);
        case SafeletUnitModeReset:
            return NSLocalizedString(@"Reset", nil);
    }
}

@end
