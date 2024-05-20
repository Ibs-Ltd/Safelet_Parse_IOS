//
//  SafeletUnitService.h
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SafeletUnit.h"
#import "BasePeripheral.h"
#import "GenericConstants.h"
#import "Firmware.h"
#import <YmsCoreBluetooth/YMSCBCentralManager.h>
#import <YmsCoreBluetooth/YMSCBStoredPeripherals.h>

@interface SafeletUnitManager : YMSCBCentralManager

@property (nonatomic, readonly) BluetoothConnectionStatus currentBluetoothStatus;
@property (strong, nonatomic) SafeletUnit *safeletPeripheral;
@property (nonatomic) BOOL dfuInProgress;

/**
 Return singleton instance.
 */
+ (instancetype)shared;

/**
 *  Scans for a non-paired Safelet Unit and connects to it
 *
 *  @param completion completion to be called once scanning has finished
 *         - safelet => a CONNECTED SafeletUnit instance (meaning you can interact with it, it's NOT created a new relation)
 *         - error   => the encountered error
 */
- (void)connectNewSafeletWithCompletionBlock:(void(^)(SafeletUnit *safelet, NSError *error))completion;

/**
 *  Creates a relation between the Safelet Unit and the current device. (by setting the Relation characteristic; see docs)
 *  After the relation characteristic is set, subscribes for receiving notifications from the Emergency characteristic
 *
 *  @param safelet    the Safelet device that we want to relate
 *  @param completion the completion block
 *         - safelet => a related SafeletUnit instance
 *         - error   => the encountered error
 */
- (void)createRelationForSafelet:(SafeletUnit *)safelet completion:(void(^)(SafeletUnit *safelet, NSError *error))completion;

/**
 *  Clears the Relation characteristic value by setting the byte 0x0. Also disconnects the Safelet and removes it from
 *  the stored devices array
 *
 *  @param completion completion block
 */
- (void)removeRelationForCurrentSafeletWithCompletion:(BluetoothErrorBlock)completion;

/**
 *  Exits the Safelet device from the Emergency State (by setting the appropriate value to the Mode characteristic). 
 *  It will enter its default state (Sleeping)
 *
 *  @param completion completion block
 */
- (void)exitEmergencyModeForConnectedDevice:(BluetoothErrorBlock)completion;

- (void)updateConnectedSafeletWithNewFirmware:(Firmware *)firmware
                                     progress:(void(^)(float progress, FirmwareUpdateProgressType progressType))progressBlock
                                   completion:(BluetoothErrorBlock)completion;

- (void)softResetConnectedSafelet:(BluetoothErrorBlock)completion;

- (void)performDispatchAlarmConfirmation:(BluetoothErrorBlock)completion;

- (void)performJoinAlarmConfirmationWithUserName:(NSString *)userName 
                                      completion:(BluetoothErrorBlock)completion;

- (void)removeRelationForDisconnectedCurrentDevice;

- (void)handleConnectionWithSafelet:(BOOL)isSuccessful;

- (void)handleBraceletButtonPressNotification;

- (void)resetCBCentralManager:(BluetoothErrorBlock)reconnectionCallback;

@end
