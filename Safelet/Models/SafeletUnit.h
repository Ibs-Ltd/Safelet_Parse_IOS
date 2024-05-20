//
//  SafeletUnit.h
//  Safelet
//
//  Created by Alex Motoc on 27/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BasePeripheral.h"
#import "SafeletBLEService.h"
#import "SafeletDeviceInfoService.h"
#import "SafeletBatteryService.h"
#import "SBandBLEService.h"
#import "Firmware.h"
#import "BlockTypes.h"

@import YmsCoreBluetooth;

static NSString * const kConnectedSafeletIdentifierKey = @"safeletIdentifier";

@interface SafeletUnit : BasePeripheral

@property (strong, nonatomic, readonly) SafeletBLEService *safeletBLE;
@property (strong, nonatomic, readonly) SBandBLEService *sbandBLE;
@property (strong, nonatomic, readonly) SafeletDeviceInfoService *deviceInfo;
@property (strong, nonatomic, readonly) SafeletBatteryService *batteryService;
@property (nonatomic, readonly) BOOL isSBand;
@property (nonatomic, readonly) NSInteger batteryLevel;

/**
 *  The name used by the device when in advertising mode; this is needed to filter the devices we scan
 *
 *  @return name of the device for advertising mode ("open for relations mode")
 */
+ (NSArray <NSString *> *)knownPeripheralNames;


/**
 The services to scan for when we want to detect the Safelet device.
 Contains SafeletBLEService and SBandBLEService

 @return the CBUUID services
 */
+ (NSArray <CBUUID *> *)safeletServices;

/**
 *  Connects the Safelet device to CBManager, such that you can interact with it.
 *  After the connection is successful, it scans for the available services and characteristics
 *
 *  @param completion completion block
 */
- (void)discoverSafeletServicesWithCompletion:(void(^)(SafeletUnit *safelet,
                                                       NSError *error))completion;

- (void)createRelation:(BluetoothErrorBlock)completion;

- (void)removeRelation:(BluetoothErrorBlock)completion;

- (void)exitEmergencyMode:(BluetoothErrorBlock)completion;

- (void)confirmDispatchAlarm:(BluetoothErrorBlock)completion;

- (void)confirmJoinAlarmWithUserName:(NSString *)userName
                          completion:(BluetoothErrorBlock)completion;

// checks if the bracelet is paired (and has a relation) with the current device (phone)
- (void)checkPhoneRelation:(void(^)(BOOL paired, NSError *error))completion;

// checks if the bracelet is in alarm mode (i.e. user pressed the bracelet button to dispatch alarm)
- (void)checkEmergencyMode:(void(^)(BOOL alarmMode, NSError *error))completion;

- (void)setButtonPressNotificationsEnabled:(BOOL)enabled completion:(BluetoothErrorBlock)completion;

- (void)reset:(void(^)(NSError *))completion;

- (void)handleBatteryCharacteristicNotification:(YMSCBCharacteristic *)yc error:(NSError *)error;

- (void)startSpecificRoutines;

- (void)updateFirmware:(Firmware *)firmware
              progress:(void(^)(float progress, FirmwareUpdateProgressType progressType))progressBlock
            completion:(BluetoothErrorBlock)completion;

@end
