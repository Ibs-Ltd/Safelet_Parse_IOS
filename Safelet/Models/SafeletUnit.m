//
//  SafeletUnit.m
//  Safelet
//
//  Created by Alex Motoc on 27/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SafeletUnit.h"
#import "SafeletUnit+SBand.h"
#import "SafeletUnit+Safelet.h"
#import "SLError.h"
#import "SafeletUnitManager.h"
#import "NSException+NSError.h"
#import "SLNotificationCenterNotifications.h"
#import "SBandDFUController.h"

static NSString * const kNameForAdvertisingMode = @"Safelet(conn.)";
static NSString * const kSBandNameForAdvertisingMode = @"sband(conn.)";

@interface SafeletUnit ()
@property (copy, nonatomic) void(^discoverSafeletCompletion)(SafeletUnit *safelet, NSError *error);
@property (nonatomic) BOOL servicesDiscovered;
@end

@implementation SafeletUnit

#pragma mark - initializations

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(YMSCBCentralManager *)owner baseHi:(int64_t)hi baseLo:(int64_t)lo {
    self = [super initWithPeripheral:peripheral central:owner baseHi:hi baseLo:lo];
    
    if (self) {
        SafeletBLEService *safeletService = [[SafeletBLEService alloc] initWithName:[SafeletBLEService serviceName]
                                                                             parent:self
                                                                         serviceUUID:[SafeletBLEService serviceUUID]];
        
        SBandBLEService *sbandService = [[SBandBLEService alloc] initWithName:[SBandBLEService serviceName]
                                                                       parent:self
                                                                  serviceUUID:[SBandBLEService serviceUUID]];
        
        SafeletDeviceInfoService *devInfo = [[SafeletDeviceInfoService alloc] initWithName:[SafeletDeviceInfoService serviceName]
                                                                                    parent:self
                                                                                    baseHi:0
                                                                                    baseLo:0
                                                                             serviceOffset:[SafeletDeviceInfoService serviceUUID]];
        
        SafeletBatteryService *batteryService = [[SafeletBatteryService alloc] initWithName:[SafeletBatteryService serviceName]
                                                                                     parent:self
                                                                                     baseHi:0
                                                                                     baseLo:0
                                                                              serviceOffset:[SafeletBatteryService serviceUUID]];
        
        self.serviceDict = @{[SafeletBLEService serviceName]: safeletService,
                             [SBandBLEService serviceName]: sbandService,
                             [SafeletDeviceInfoService serviceName]: devInfo,
                             [SafeletBatteryService serviceName]: batteryService};
    }
    
    return self;
}

#pragma mark - logic

- (void)dispatchBatteryChangedNotification:(NSInteger)battery {
    [[NSNotificationCenter defaultCenter] postNotificationName:SLBraceletBatteryChangedNotification
                                                        object:nil
                                                      userInfo:@{SLBraceletBatteryChangedNotification:@(battery)}];
}

- (void)startSpecificRoutines {
    _batteryLevel = -1; // -1 because not read yet
    [(SafeletUnitManager *)self.central handleConnectionWithSafelet:YES];
    
    [self setButtonPressNotificationsEnabled:YES completion:nil];
    [self.deviceInfo readDeviceInfo];
    if (self.isSBand) {
        [self updateSBandTime:nil];
    }
    
    [self readBatteryLevelWithCompletion:^(NSInteger batteryLevel, NSError *error) {
        [self enableBatteryValueChangedNotification:nil];
    }];
}

- (void)discoverSafeletServicesWithCompletion:(void (^)(SafeletUnit *, NSError *))completion {
    // Watchdog aware method
    [self resetWatchdog];
    
    self.discoverSafeletCompletion = completion;
    SafeletUnitManager *manager = (SafeletUnitManager *)self.central;
    
    __weak typeof(self) this = self;
    [self discoverServices:[self services] withBlock:^(NSArray *yservices, NSError *error) {
        if (error) {
            [manager handleConnectionWithSafelet:NO];
            if (completion) {
                _YMS_PERFORM_ON_MAIN_THREAD(^(){
                    completion(this, error);
                });
            }
            return;
        }
        
        __block NSInteger servCount = 0;
        for (YMSCBService *service in yservices) {
            [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                servCount += 1;
                
                if (error) {
                    NSLog(@"BLUETOOTH - failed characteristics for service %@: %@", service.name, [service characteristics]);
                    if ([service.name isEqualToString:[SafeletBLEService serviceName]] ||
                        [service.name isEqualToString:[SBandBLEService serviceName]]) {
                        [manager handleConnectionWithSafelet:NO];
                        _YMS_PERFORM_ON_MAIN_THREAD(^(){
                            completion == nil ?: completion(this, error);
                        });
                        return;
                    }
                }
                
                if (servCount == yservices.count) {
                    self.servicesDiscovered = YES;
                    _YMS_PERFORM_ON_MAIN_THREAD(^(){
                        completion == nil ?: completion(this, nil);
                    });
                }
            }];
        }
    }];
}

- (void)createRelation:(void (^)(NSError *))completion {
    NSInteger length = 16;
    BaseCharacteristic *relation = self.safeletBLE.relation;
    if (self.isSBand) {
        relation = self.sbandBLE.relationCharacteristic;
        length = 6;
    }
    
    uuid_t bytes;
    NSUUID *deviceUUID = [[UIDevice currentDevice] identifierForVendor];
    [deviceUUID getUUIDBytes:bytes];
    NSData *data = [NSData dataWithBytes:bytes length:length];
    
    @try {
        [relation writeValue:data withBlock:^(NSError *error) {
            if (error) {
                _YMS_PERFORM_ON_MAIN_THREAD(^(){
                    completion == nil ?: completion(error);
                });
                return;
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:[self.cbPeripheral.identifier UUIDString]
                                                      forKey:kConnectedSafeletIdentifierKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self startSpecificRoutines];
            
            _YMS_PERFORM_ON_MAIN_THREAD(^(){
                completion == nil ?: completion(nil);
            });
        }];
    } @catch (NSException *exception) {
        NSLog(@"BLUETOOTH - caught exception: %@", exception);
        completion([exception toError]);
    }
}

- (void)removeRelation:(void (^)(NSError * _Nullable))completion {
    self.isSBand ? [self removeSBandRelation:completion] : [self removeSafeletRelation:completion];
}

- (void)exitEmergencyMode:(void (^)(NSError * _Nullable))completion {
    self.isSBand ? [self exitSBandEmergencyMode:completion] : [self.safeletBLE.mode setModeTo:SafeletUnitModeCancelEmergency completion:completion];
}

- (void)confirmDispatchAlarm:(void (^)(NSError * _Nullable))completion {
    self.isSBand ? [self confirmSBandDispatchAlarm:completion] : [self confirmSafeletDispatchAlarm:completion];
}

- (void)confirmJoinAlarmWithUserName:(NSString *)userName completion:(void (^)(NSError *))completion {
    // for safelet bracelet confirmJoinAlarm is the same as confirmSafeletDispatchAlarm
    self.isSBand ? [self confirmSBandJoinAlarmWithUserName:userName completion:completion] : [self confirmSafeletDispatchAlarm:completion];
}

- (void)checkPhoneRelation:(void (^)(BOOL, NSError * _Nullable))completion {
    void (^checkRelation)(NSData *data, NSError *error) = ^void(NSData *data, NSError *error) {
        if (error) {
            completion(NO, error);
            return;
        }
        
        uuid_t bytes;
        NSUUID *deviceUUID = [[UIDevice currentDevice] identifierForVendor];
        [deviceUUID getUUIDBytes:bytes];
        
        NSInteger length = 16;
        if (self.isSBand) {
            length = 6;
        }
        NSData *uuidData = [NSData dataWithBytes:bytes length:length];
        
        data = [data subdataWithRange:NSMakeRange(0, length)];
        _YMS_PERFORM_ON_MAIN_THREAD(^(){
            if ([data isEqualToData:uuidData]) {
                completion(YES, nil);
            } else {
                completion(NO, nil);
            }
        });
    };
    
    BaseCharacteristic *relation = self.safeletBLE.relation;
    if (self.isSBand) {
        relation = self.sbandBLE.relationCharacteristic;
    }
    
    @try {
        [relation readValueWithBlock:checkRelation];
    } @catch (NSException *exception) {
        NSLog(@"BLUETOOTH - caught exception: %@", exception);
        completion(NO, [exception toError]);
    }
}

- (void)checkEmergencyMode:(void (^)(BOOL, NSError * _Nullable))completion {
    self.isSBand ? [self checkSBandEmergencyMode:completion] : [self checkSafeletEmergencyMode:completion];
}

- (void)setButtonPressNotificationsEnabled:(BOOL)enabled completion:(void (^)(NSError * _Nonnull))completion {
    BaseCharacteristic *notify = self.safeletBLE.emergency;
    if (self.isSBand) {
        notify = self.sbandBLE.buttonCharacteristic;
    }
    
    @try {
        [notify setNotifyValue:enabled withBlock:^(NSError *error) {
            _YMS_PERFORM_ON_MAIN_THREAD(^(){
                completion == nil ?: completion(error);
            });
        }];
    } @catch (NSException *exception) {
        NSLog(@"BLUETOOTH - caught exception: %@", exception);
        completion([exception toError]);
    }
}

- (void)reset:(void (^)(NSError * _Nonnull))completion {
    if (self.isSBand) {
        @try {
            [self.sbandBLE.modeCharacteristic writeByte:SafeletUnitModeReset withBlock:^(NSError *error) {
                _YMS_PERFORM_ON_MAIN_THREAD(^(){
                    completion == nil ?: completion(error);
                });
            }];
        } @catch (NSException *exception) {
            NSLog(@"BLUETOOTH - caught exception: %@", exception);
            completion([exception toError]);
        }
        return;
    }
    
    [self.safeletBLE.mode readCurrentMode:^(SafeletUnitMode mode, NSError *error) {
        if (mode != SafeletUnitModeSleeping && mode != SafeletUnitModeImageUPD) {
            NSString *format = NSLocalizedString(@"Can't soft reset from current Safelet mode: %@ (%ld). The Safelet must be in mode Sleeping (0)", nil);
            NSString *reason = [NSString stringWithFormat:format, [ModeCharacteristic convertToString:mode], mode];
            NSError *error = [SLError errorWithCode:SLErrorCodeInvalidSafeletMode failureReason:reason];
            
            _YMS_PERFORM_ON_MAIN_THREAD(^(){
                completion == nil ?: completion(error);
            });
            
            return;
        }
        
        [self.safeletBLE.mode setModeTo:SafeletUnitModeReset completion:^(NSError *error) {
            _YMS_PERFORM_ON_MAIN_THREAD(^(){
                completion == nil ?: completion(error);
            });
        }];
    }];
}

- (void)readBatteryLevelWithCompletion:(void (^)(NSInteger batteryLevel, NSError *error))completion {
    BaseCharacteristic *battery = self.batteryService.battery;
    if (self.isSBand) {
        battery = self.sbandBLE.batteryPercentageCharacteristic;
    }
    
    [battery readIntegerValue:^(NSInteger value, NSError *error) {
        if (error) {
            completion == nil ?: completion(-1, error);
            return;
        }
        
        if (self->_batteryLevel == -1 && value == 0 && self.isSBand) {
            [self readBatteryLevelWithCompletion:completion];
            return;
        }
        
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            if (value != self.batteryLevel) {
                self->_batteryLevel = value;
                [self dispatchBatteryChangedNotification:value];
            }
            
            if (completion) {
                completion(value, nil);
            }
        });
    }];
}

- (void)enableBatteryValueChangedNotification:(BluetoothErrorBlock)completion {
    BaseCharacteristic *battery = self.batteryService.battery;
    if (self.isSBand) {
        battery = self.sbandBLE.batteryPercentageCharacteristic;
    }
    
    [battery setNotifyValue:YES withBlock:^(NSError *error) {
        completion == nil ?: completion(error);
    }];
}

- (void)handleBatteryCharacteristicNotification:(YMSCBCharacteristic *)yc error:(NSError *)error {
    if (error) {
        _YMS_PERFORM_ON_MAIN_THREAD(^(){
           [self dispatchBatteryChangedNotification:-1];
        });
        return;
    }
    
    UInt8 bytes;
    [yc.cbCharacteristic.value getBytes:&bytes length:1];
    
    _YMS_PERFORM_ON_MAIN_THREAD(^{
        self->_batteryLevel = bytes;
        [self dispatchBatteryChangedNotification:bytes];
    });
}

- (void)updateFirmware:(Firmware *)firmware
              progress:(void (^)(float, FirmwareUpdateProgressType))progressBlock
            completion:(void (^)(NSError *))completion {
    if (self.isSBand) {
        [[SBandDFUController shared] updateSBand:self
                                        firmware:firmware
                                        progress:progressBlock
                                      completion:completion];
    } else {
        [self updateSafeletFirmware:firmware
                           progress:progressBlock
                         completion:completion];
    }
}

#pragma mark - utils

- (BOOL)isConnected {
    return [super isConnected] && self.servicesDiscovered;
}

- (BOOL)isSBand {
    return self.sbandBLE.cbService != nil;
}

- (void)defaultConnectionHandler {
    if (self.cbPeripheral.state != CBPeripheralStateConnected && self.discoverSafeletCompletion) {
        NSError *err = [SLError errorWithCode:SLErrorCodeFailedToConnectSafelet
                                failureReason:@""];
        
        _YMS_PERFORM_ON_MAIN_THREAD(^(){
            self.discoverSafeletCompletion(self, err);
            self.discoverSafeletCompletion = nil;
        });
    }
}

#pragma mark - Getters

- (SafeletBLEService *)safeletBLE {
    return self.serviceDict[[SafeletBLEService serviceName]];
}

- (SBandBLEService *)sbandBLE {
    return self.serviceDict[[SBandBLEService serviceName]];
}

- (SafeletDeviceInfoService *)deviceInfo {
    return self.serviceDict[[SafeletDeviceInfoService serviceName]];
}

- (SafeletBatteryService *)batteryService {
    return self.serviceDict[[SafeletBatteryService serviceName]];
}

+ (NSArray<NSString *> *)knownPeripheralNames {
    return @[kNameForAdvertisingMode, kSBandNameForAdvertisingMode];
}

+ (NSArray<CBUUID *> *)safeletServices {
    return @[SafeletBLEService.serviceCBUUID, SBandBLEService.serviceCBUUID];
}

@end
