//
//  SBandBLEService.m
//  Safelet
//
//  Created by Alexandru Motoc on 10/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SBandBLEService.h"
#import "SafeletUnitManager.h"
#import <YmsCoreBluetooth/YMSCBUtils.h>

static int64_t const kUUIDValueHi = 0x0000200000001000;
static int64_t const kUUIDValueLo = 0x800000805F9B34FB;

static NSString * const kModeCharacteristic = @"mode";
static NSString * const kRelationCharacteristic = @"relation";
static NSString * const kButtonCharacteristic = @"button";
static NSString * const kVibrationControlCharacteristic = @"vibrationControl";
static NSString * const kVibrationPeriodCharacteristic = @"vibrationPeriod";
static NSString * const kBatteryPercentageCharacteristic = @"batteryLevel";
static NSString * const kBatteryStatusCharacteristic = @"batteryStatus";
static NSString * const kStepCounterCharacteristic = @"steps";
static NSString * const kTextCharacteristic1 = @"text1";
static NSString * const kTextCharacteristic2 = @"text2";
static NSString * const kDisplayCharacteristic = @"display";
static NSString * const kRTCSyncCharacteristic = @"rtc";

@implementation SBandBLEService

- (instancetype)initWithName:(NSString *)name parent:(YMSCBPeripheral *)pObj serviceUUID:(yms_u128_t)offset {
    self = [super initWithName:name parent:pObj serviceUUID:offset];
    
    if (self) {
        [self addBaseCharacteristic:kModeCharacteristic withAddress:0x2E00];
        [self addBaseCharacteristic:kRelationCharacteristic withAddress:0x2E01];
        [self addBaseCharacteristic:kVibrationControlCharacteristic withAddress:0x2E02];
        [self addBaseCharacteristic:kVibrationPeriodCharacteristic withAddress:0x2E03];
        [self addBaseCharacteristic:kButtonCharacteristic withAddress:0x2E04];
        [self addBaseCharacteristic:kBatteryPercentageCharacteristic withAddress:0x2E05];
        [self addBaseCharacteristic:kBatteryStatusCharacteristic withAddress:0x2E06];
        [self addBaseCharacteristic:kDisplayCharacteristic withAddress:0x2E07];
        [self addBaseCharacteristic:kTextCharacteristic1 withAddress:0x2E08];
        [self addBaseCharacteristic:kTextCharacteristic2 withAddress:0x2E09];
        [self addBaseCharacteristic:kStepCounterCharacteristic withAddress:0x2E0A];
        [self addBaseCharacteristic:kRTCSyncCharacteristic withAddress:0x2E0B];
        
        self.modeCharacteristic = self.characteristicDict[kModeCharacteristic];
        self.relationCharacteristic = self.characteristicDict[kRelationCharacteristic];
        self.buttonCharacteristic = self.characteristicDict[kButtonCharacteristic];
        self.vibrationControlCharacteristic = self.characteristicDict[kVibrationControlCharacteristic];
        self.vibrationPeriodCharacteristic = self.characteristicDict[kVibrationPeriodCharacteristic];
        self.batteryPercentageCharacteristic = self.characteristicDict[kBatteryPercentageCharacteristic];
        self.batteryStatusCharacteristic = self.characteristicDict[kBatteryStatusCharacteristic];
        self.stepCounterCharacteristic = self.characteristicDict[kStepCounterCharacteristic];
        self.textCharacteristic1 = self.characteristicDict[kTextCharacteristic1];
        self.textCharacteristic2 = self.characteristicDict[kTextCharacteristic2];
        self.displayCharacteristic = self.characteristicDict[kDisplayCharacteristic];
        self.rTCSyncCharacteristic = self.characteristicDict[kRTCSyncCharacteristic];
    }
    
    return self;
}

+ (NSString *)serviceName {
    return @"sbandBLEService";
}

+ (yms_u128_t)serviceUUID {
    yms_u128_t offset = {kUUIDValueHi, kUUIDValueLo};
    
    return offset;
}

+ (CBUUID *)serviceCBUUID {
    yms_u128_t uuid = [self serviceUUID];
    return [YMSCBUtils createCBUUID:&uuid withIntBLEOffset:0];
}

- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
    if ([yc.name isEqualToString:kButtonCharacteristic]) {
        if (error) {
            return;
        }
        NSInteger value = [YMSCBUtils dataToByte:yc.cbCharacteristic.value];
        if (value != 0) {
            [(SafeletUnitManager *)self.parent.central handleBraceletButtonPressNotification];
        }
    }
    
    if ([yc.name isEqualToString:kBatteryPercentageCharacteristic]) {
        [(SafeletUnit *)self.parent handleBatteryCharacteristicNotification:yc error:error];
    }
}

@end
