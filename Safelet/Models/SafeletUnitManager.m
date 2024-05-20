//
//  SafeletUnitService.m
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SafeletUnitManager.h"
#import "SLErrorHandlingController.h"
#import "SLMenuSelectionController.h"
#import "SLAlarmManager.h"
#import "SLError.h"
#import "Firmware+Requests.h"
#import "Utils.h"
#import "SLDataManager.h"
#import "User+Requests.h"
#import "SLNotificationCenterNotifications.h"
#import "SafeletUnitManagerDelegate.h"
#import <UIKit/UIKit.h>

typedef void(^SafeletSoftResetBlock)(NSError *error);
typedef void(^ConnectionStatusChangeBlock)(BluetoothConnectionStatus status);

@interface SafeletUnitManager()
@property (copy, nonatomic) BluetoothErrorBlock safeletReconnectionBlock;
@property (copy, nonatomic) SafeletSoftResetBlock softResetBlock;
@property (nonatomic) BluetoothConnectionStatus connectionStatus;
@property (strong, nonatomic) SafeletUnitManagerDelegate *managerDelegate;
@end

@implementation SafeletUnitManager

#pragma mark - Constructors

+ (instancetype)shared {
    static SafeletUnitManager *manager = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        manager = [[SafeletUnitManager alloc] initWithKnownPeripheralNames:[SafeletUnit knownPeripheralNames]
                                                                     queue:nil
                                                      useStoredPeripherals:YES
                                                                  delegate:nil];
        
        SafeletUnitManagerDelegate *managerDelegate = [SafeletUnitManagerDelegate new];
        managerDelegate.connectionBlock = ^(CBCentralManager *central, CBPeripheral *peripheral) {
            [manager manager:central connectPeripheral:peripheral];
        };
        managerDelegate.disconnectionBlock = ^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
            [manager manager:central disconnectPeripheral:peripheral error:error];
        };
        
        manager.managerDelegate = managerDelegate;
        manager.delegate = manager.managerDelegate;
    });
    return manager;
}

#pragma mark - Scan and connect Safelet

- (void)connectNewSafeletWithCompletionBlock:(void (^)(SafeletUnit *, NSError *))completion {
    // NOTE: Safelet firmware does not included services in advertisementData.
    // This prevents usage of serviceUUIDs array to filter on.
    
    /*
     Note that in this implementation, handleFoundPeripheral: is implemented so that it can be used via block callback or as a
     delagate handler method. This is an implementation specific decision to handle discovered and retrieved peripherals identically.
     
     This may not always be the case, where for example information from advertisementData and the RSSI are to be factored in.
     */
    __weak SafeletUnitManager *this = self;
    [self scanForPeripheralsWithServices:SafeletUnit.safeletServices
                                 options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @NO }
                               withBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
                                   if (error) {
                                       [this stopScan];
                                       completion(nil, error);
                                       return;
                                   }
                                   
                                   // localName can be different from the actual name; should check both when trying to connect
                                   NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
                                   SafeletUnit *safelet = (SafeletUnit *)[this findPeripheral:peripheral];
                                   
                                   NSLog(@"DISCOVERED: %@, %@, %@ db; LOCAL NAME: %@", peripheral, peripheral.name, RSSI, localName);
                                   
                                   if (safelet == nil) {
                                       for (NSString *pname in this.knownPeripheralNames) {
                                           if ([pname isEqualToString:peripheral.name] || [pname isEqualToString:localName]) {
                                               [this stopScan];
                                               safelet = [[SafeletUnit alloc] initWithPeripheral:peripheral
                                                                                         central:this
                                                                                          baseHi:0
                                                                                          baseLo:0];
                                               break;
                                           }
                                       }
                                   }
                                   
                                   if (safelet) {
                                       [this addPeripheral:safelet];
                                       this.safeletPeripheral = safelet;
                                       [this stopScan];
                                       
                                       [safelet connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
                                           if (error) {
                                               [this removePeripheral:safelet];
                                               this.safeletPeripheral = nil;
                                               [this startScan];
                                               
                                               [this handleConnectionWithSafelet:NO];
                                               _YMS_PERFORM_ON_MAIN_THREAD(^(){
                                                   completion((SafeletUnit *)yp, error);
                                               });
                                               return;
                                           }
                                           
                                           _YMS_PERFORM_ON_MAIN_THREAD(^(){
                                               completion((SafeletUnit *)yp, nil);
                                           });
                                       }];
                                   }
                               }];
}

#pragma mark - Create relation with Safelet

- (void)createRelationForSafelet:(SafeletUnit *)safelet completion:(void (^)(SafeletUnit *, NSError *))completion {
    [safelet createRelation:^(NSError * _Nullable error) {
        completion(safelet, error);
    }];
}

#pragma mark - Remove relation with Safelet

- (void)removeRelationForCurrentSafeletWithCompletion:(void (^)(NSError *))completion {
    [self.safeletPeripheral removeRelation:^(NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }
        
        // need this before removing self.safeletPeripheral because the notification is sent only if there is a connected safelet
        [self notifyBluetoothStatusChanged:BluetoothConnectionStatusNoSafeletRelation];
        [SLDataManager sharedManager].presentedLowBatteryNotificationsCount = 0;
        
        [self.safeletPeripheral disconnect];
        [self removePeripheral:self.safeletPeripheral];
        self.safeletPeripheral = nil;
        
        completion(nil);
    }];
}

- (void)removeRelationForDisconnectedCurrentDevice {
    // need this before removing self.safeletPeripheral because the notification is sent only if there is a connected safelet
    [self notifyBluetoothStatusChanged:BluetoothConnectionStatusNoSafeletRelation];
    [SLDataManager sharedManager].presentedLowBatteryNotificationsCount = 0;
    
    @try {
        [self removePeripheral:self.safeletPeripheral];
    } @catch (NSException *exception) {
        NSLog(@"EXCEPTION: trying to remove bracelet from stored peripherals - %@", exception);
    }
    
    [self.safeletPeripheral disconnect];
    self.safeletPeripheral = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConnectedSafeletIdentifierKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Alarm actions

- (void)exitEmergencyModeForConnectedDevice:(void (^)(NSError *))completion {
    [self.safeletPeripheral exitEmergencyMode:completion];
}

- (void)performDispatchAlarmConfirmation:(void (^)(NSError *))completion {
    [self.safeletPeripheral confirmDispatchAlarm:completion];
}

- (void)performJoinAlarmConfirmationWithUserName:(NSString *)userName completion:(void (^)(NSError *))completion {
    [self.safeletPeripheral confirmJoinAlarmWithUserName:userName completion:completion];
}

- (void)handleBraceletButtonPressNotification {
    if ([SLAlarmManager sharedManager].alarm.isActive == NO) {
        UIApplication *app = [UIApplication sharedApplication];
        if (app.applicationState == UIApplicationStateBackground || app.applicationState == UIApplicationStateInactive) {
            [[User currentUser] dispatchAlarmWithCompletion:^(Alarm * _Nullable alarm,
                                                              NSError * _Nullable error) {
                if (alarm) {
                    [SLAlarmManager handleDispatchAlarm:alarm shouldPlaySound:YES];
                    [[SafeletUnitManager shared] performDispatchAlarmConfirmation:nil];
                }
            }];
            
            return;
        } else {
            [[SLMenuSelectionController sharedController] handleAlarmSelectionFromMenu:nil];
        }
    }
}

#pragma mark - Reset

- (void)softResetConnectedSafelet:(void (^)(NSError *))completion {
    [self.safeletPeripheral reset:^(NSError * _Nonnull error) {
        self.softResetBlock = completion;
    }];
}

- (void)resetCBCentralManager:(BluetoothErrorBlock)reconnectionCallback {
    self.safeletPeripheral = nil;
    self.safeletReconnectionBlock  = reconnectionCallback;
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

#pragma mark - Update Safelet firmware

- (void)updateConnectedSafeletWithNewFirmware:(Firmware *)firmware
                                     progress:(void (^)(float, FirmwareUpdateProgressType))progressBlock
                                   completion:(void (^)(NSError *))completion {
    [self.safeletPeripheral updateFirmware:firmware progress:progressBlock completion:completion];
}

#pragma mark - Connection handlers

- (void)callResetBlocks:(NSError *)error {
    if (self.softResetBlock) {
        self.softResetBlock(error);
        self.softResetBlock = nil;
    }
    
    if (self.safeletReconnectionBlock) {
        self.safeletReconnectionBlock(error);
        self.safeletReconnectionBlock = nil;
    }
}

- (void)handleReconnectionError:(NSError *)error {
    [self callResetBlocks:error];
    [SLErrorHandlingController handleSafeletBluetoothConnectionError];
    [self removeRelationForDisconnectedCurrentDevice];
}

- (void)handleDisconnectedSafeletWithConnection:(BOOL)connect completion:(BluetoothErrorBlock)completion {
    void(^workBlock)(BluetoothErrorBlock) = ^(BluetoothErrorBlock completion) {
        [self.safeletPeripheral discoverSafeletServicesWithCompletion:^(SafeletUnit *safelet, NSError *error) {
            if (error) {
                [self handleReconnectionError:error];
                return;
            }
            
            [safelet checkPhoneRelation:^(BOOL paired, NSError * _Nullable error) {
                if (error) {
                    [self handleReconnectionError:error];
                    return;
                }
                
                if (paired) {
                    [self callResetBlocks:nil];
                    
                    [safelet checkEmergencyMode:^(BOOL alarmMode, NSError * _Nullable error) {
                        completion == nil ?: completion(error);
                        
                        [safelet startSpecificRoutines];
                        if (error) {
                            return;
                        }
                        if ([SLAlarmManager sharedManager].alarm.isActive == NO && alarmMode) {
                            [[SLMenuSelectionController sharedController] handleAlarmSelectionFromMenu:nil];
                        }
                    }];
                } else { // the connected safelet is not correctly paired with the phone
                    [self callResetBlocks:[SLError errorWithCode:SLErrorCodeFailedToConnectSafelet
                                                   failureReason:NSLocalizedString(@"Bracelet not paired", nil)]];
                    [self handleConnectionWithSafelet:NO];
                    
                    [self removeRelationForCurrentSafeletWithCompletion:^(NSError *error) {
                        completion == nil ?: completion(error);
                        if (error) {
                            [SLErrorHandlingController handleError:error];
                        } else {
                            [UIAlertController showAlertWithMessage:NSLocalizedString(@"The Safelet bracelet and the Safelet app are not longer connected. They are ready to reconnect", nil)];
                        }
                    }];
                }
            }];
        }];
    };
    
    if (connect) {
        [self.safeletPeripheral connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
            if (error) {
                [self handleReconnectionError:error];
                return;
            }
            workBlock(completion);
        }];
    } else {
        workBlock(completion);
    }
}

- (void)handleDisconnectedSafelet:(BluetoothErrorBlock)completion {
    [self handleDisconnectedSafeletWithConnection:YES completion:completion];
}

- (void)rescanPairedSafeletServices:(BluetoothErrorBlock)completion {
    [self handleDisconnectedSafeletWithConnection:NO completion:completion];
}

- (void)handleDisconnectedSafelet {
    [self handleDisconnectedSafeletWithConnection:YES completion:nil];
}

- (void)handleConnectionWithSafelet:(BOOL)isSuccessful {
    BluetoothConnectionStatus status = BluetoothConnectionStatusDisconnected;
    if (isSuccessful) {
        status = BluetoothConnectionStatusConnected;
    }
    [self notifyBluetoothStatusChanged:status];
}

#pragma mark - bluetooth status

- (BluetoothConnectionStatus)currentBluetoothStatus {
    return self.connectionStatus;
}

- (void)managerPoweredOnHandler {
    if (self.useStoredPeripherals && self.safeletPeripheral == nil) {
        NSArray *identifiers = [YMSCBStoredPeripherals genIdentifiers];
        NSArray *peripherals = [self retrievePeripheralsWithIdentifiers:identifiers];
        
        NSString *safeletUUID = [[NSUserDefaults standardUserDefaults] objectForKey:kConnectedSafeletIdentifierKey];
        
        for (CBPeripheral *peripheral in peripherals) {
            if ([[peripheral.identifier UUIDString] isEqualToString:safeletUUID]) {
                self.safeletPeripheral = [[SafeletUnit alloc] initWithPeripheral:peripheral
                                                                         central:self
                                                                          baseHi:0
                                                                          baseLo:0];
                [self addPeripheral:self.safeletPeripheral];
                [self handleDisconnectedSafelet];
                
                break;
            }
        }
        
        if ( self.safeletPeripheral == nil) {
            [self notifyBluetoothStatusChanged:BluetoothConnectionStatusNoSafeletRelation];
        }
    } else if (self.safeletPeripheral) {
        [self handleDisconnectedSafelet];
    } else {
        [self notifyBluetoothStatusChanged:BluetoothConnectionStatusNoSafeletRelation];
    }
}

- (void)managerPoweredOffHandler {
    // reset this, because the Safelet might get connected with a different battery level
    [SLDataManager sharedManager].presentedLowBatteryNotificationsCount = 0;
    [self notifyBluetoothStatusChanged:BluetoothConnectionStatusPoweredOff];
}

- (void)managerUnauthorizedHandler {
    [self notifyBluetoothStatusChanged:BluetoothConnectionStatusUnsupported];
}

- (void)managerUnsupportedHandler {
    [self notifyBluetoothStatusChanged:BluetoothConnectionStatusUnsupported];
}

- (void)notifyBluetoothStatusChanged:(BluetoothConnectionStatus)status {
    self.connectionStatus = status;
    
    _YMS_PERFORM_ON_MAIN_THREAD(^() {
        [[NSNotificationCenter defaultCenter] postNotificationName:SLBluetoothStateChangedNotification
                                                            object:nil
                                                          userInfo:@{SLBluetoothStateChangedNotification:@(status)}];
    });
}

#pragma mark - Connection/Disconnection handlers

- (void)manager:(CBCentralManager *)central disconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"DID DISCONNECT - %@", peripheral);
    if ([self.safeletPeripheral.name isEqualToString:peripheral.name]) {
        // reset this, because the Safelet might get connected with a different battery level
        [SLDataManager sharedManager].presentedLowBatteryNotificationsCount = 0;
        
        if (self.dfuInProgress == NO) {
            __weak typeof(self) this = self;
            
            NSLog(@"START SCANNING");
            [self scanForPeripheralsWithServices:SafeletUnit.safeletServices
                                         options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @NO }
                                       withBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
                                           NSLog(@"FOUND A DEVICE: %@\nDATA: %@", peripheral, advertisementData);
                                           
                                           NSString *peripheralUUID = peripheral.identifier.UUIDString;
                                           NSString *safeletUUID = this.safeletPeripheral.cbPeripheral.identifier.UUIDString;
                                           if ([peripheralUUID isEqualToString:safeletUUID]) {
                                               NSLog(@"FOUND CURRENT PAIRED DEVICE");
                                               [this stopScan];
                                               [this handleDisconnectedSafelet];
                                           }
                                       }];
        }
        
        if (self.connectionStatus == BluetoothConnectionStatusConnected) {
            [self notifyBluetoothStatusChanged:BluetoothConnectionStatusDisconnected];
        }
    }
}

- (void)manager:(CBCentralManager *)central connectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"DID CONNECT - %@", peripheral);
}

@end
