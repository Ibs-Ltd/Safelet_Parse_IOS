//
//  SafeletBLEService.m
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SafeletBLEService.h"
#import "SLMenuSelectionController.h"
#import "SLAlarmManager.h"
#import "User+Requests.h"
#import "SafeletUnitManager.h"
#import "SLAlarmPlaybackManager.h"
#import <YmsCoreBluetooth/YMSCBUtils.h>

static int64_t const kUUIDValueHi = 0x9e0089baf0796897;
static int64_t const kUUIDValueLo = 0x7546c22b47707b6e;

@implementation SafeletBLEService

- (instancetype)initWithName:(NSString *)name parent:(YMSCBPeripheral *)pObj serviceUUID:(yms_u128_t)offset {
    self = [super initWithName:name parent:pObj serviceUUID:offset];
    
    if (self) {
        [self addCharacteristic:[ModeCharacteristic class] serviceUUID:[ModeCharacteristic characteristicUUID]];
        [self addCharacteristic:[RelationCharacteristic class] serviceUUID:[RelationCharacteristic characteristicUUID]];
        [self addCharacteristic:[EmergencyCharacteristic class] serviceUUID:[EmergencyCharacteristic characteristicUUID]];
        [self addCharacteristic:[LEDControlCharacteristic class] serviceUUID:[LEDControlCharacteristic characteristicUUID]];
        [self addCharacteristic:[FirmwareUpdateCharacteristic class] serviceUUID:[FirmwareUpdateCharacteristic characteristicUUID]];
        [self addCharacteristic:[AlarmSentApprovalCharacteristic class] serviceUUID:[AlarmSentApprovalCharacteristic characteristicUUID]];
    }
    
    return self;
}

+ (NSString *)serviceName {
    return @"safeletBLE";
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
    if (error) {
        return;
    }
    
    if ([yc isKindOfClass:[EmergencyCharacteristic class]]) {
        NSInteger value = [YMSCBUtils dataToByte:yc.cbCharacteristic.value];
        if (value != 0) {
            [(SafeletUnitManager *)self.parent.central handleBraceletButtonPressNotification];
        }
    }
}

#pragma mark - Getters

- (ModeCharacteristic *)mode {
    return self.characteristicDict[[ModeCharacteristic characteristicName]];
}

- (RelationCharacteristic *)relation {
    return self.characteristicDict[[RelationCharacteristic characteristicName]];
}

- (EmergencyCharacteristic *)emergency {
    return self.characteristicDict[[EmergencyCharacteristic characteristicName]];
}

- (LEDControlCharacteristic *)ledControl {
    return self.characteristicDict[[LEDControlCharacteristic characteristicName]];
}

- (FirmwareUpdateCharacteristic *)firmwareUpdate {
    return self.characteristicDict[[FirmwareUpdateCharacteristic characteristicName]];
}

- (AlarmSentApprovalCharacteristic *)alarmSentApproval {
    return self.characteristicDict[[AlarmSentApprovalCharacteristic characteristicName]];
}

@end
