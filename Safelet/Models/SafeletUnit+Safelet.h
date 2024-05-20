//
//  SafeletUnit+Safelet.h
//  Safelet
//
//  Created by Alexandru Motoc on 12/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SafeletUnit.h"

@interface SafeletUnit (Safelet)

- (void)removeSafeletRelation:(void(^)(NSError *error))completion;
- (void)confirmSafeletDispatchAlarm:(void(^)(NSError *error))completion;
- (void)checkSafeletEmergencyMode:(void(^)(BOOL alarmMode, NSError *error))completion;
- (void)updateSafeletFirmware:(Firmware *)firmware
                     progress:(void(^)(float progress, FirmwareUpdateProgressType progressType))progressBlock
                   completion:(void(^)(NSError *error))completion;

@end
