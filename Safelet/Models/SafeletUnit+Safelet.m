//
//  SafeletUnit+Safelet.m
//  Safelet
//
//  Created by Alexandru Motoc on 12/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SafeletUnit+Safelet.h"
#import "NSException+NSError.h"
#import "SafeletUnitManager.h"
#import <UIKit/UIKit.h>

@implementation SafeletUnit (Safelet)

- (void)removeSafeletRelation:(void (^)(NSError *))completion {
    @try {
        [self.safeletBLE.relation writeByte:0 withBlock:^(NSError *error) {
            if (error) {
                completion == nil ?: completion(error);
                return;
            }
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConnectedSafeletIdentifierKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (completion) {
                completion(error);
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"BLUETOOTH - caught exception: %@", exception);
        completion([exception toError]);
    }
}

- (void)confirmSafeletDispatchAlarm:(void (^)(NSError *))completion {
    @try {
        [self.safeletBLE.alarmSentApproval writeByte:0x01 withBlock:^(NSError *error) {
            if (completion) {
                completion(error);
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"BLUETOOTH - caught exception: %@", exception);
        completion([exception toError]);
    }
}

- (void)checkSafeletEmergencyMode:(void (^)(BOOL, NSError *))completion {
    @try {
        [self.safeletBLE.mode readCurrentMode:^(SafeletUnitMode mode, NSError *error) {
            completion(mode == SafeletUnitModeConnectedEmergency, error);
        }];
    } @catch (NSException *exception) {
        NSLog(@"BLUETOOTH - caught exception: %@", exception);
        completion(NO, [exception toError]);
    }
}

- (void)updateSafeletFirmware:(Firmware *)firmware
                     progress:(void (^)(float, FirmwareUpdateProgressType))progressBlock
                   completion:(void (^)(NSError *))completion {
    if (completion == nil) {
        return;
    }
    
    __weak typeof(self) this = self;
    [self.safeletBLE.mode setModeTo:SafeletUnitModeImageUPD completion:^(NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        [firmware.updatefile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            [this.safeletBLE.firmwareUpdate writeNewFirmwareData:data progress:^(float progress) {
                if (progressBlock) {
                    progressBlock(progress, FirmwareUpdateProgressTypeInstalling);
                }
            } completion:^(NSError *error) {
                if (error) {
                    completion(error);
                    return;
                }
                
                if (progressBlock) {
                    progressBlock(0, FirmwareUpdateProgressTypeResetting);
                }
                
                [(SafeletUnitManager *)this.central softResetConnectedSafelet:^(NSError *error) {
                    if (error) {
                        completion(error);
                        return;
                    }
                    
                    completion(nil);
                }];
            }];
        } progressBlock:^(int percentDone) {
            if (progressBlock) {
                progressBlock((float)percentDone / 100.0f, FirmwareUpdateProgressTypeDownloading);
            }
        }];
    }];
}

@end
