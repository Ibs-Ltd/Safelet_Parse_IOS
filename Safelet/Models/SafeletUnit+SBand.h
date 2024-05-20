//
//  SafeletUnit+SBand.h
//  Safelet
//
//  Created by Alexandru Motoc on 12/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SafeletUnit.h"

@interface SafeletUnit (SBand)

- (void)removeSBandRelation:(BluetoothErrorBlock)completion;
- (void)confirmSBandDispatchAlarm:(BluetoothErrorBlock)completion;
- (void)confirmSBandJoinAlarmWithUserName:(NSString *)userName completion:(BluetoothErrorBlock)completion;
- (void)checkSBandEmergencyMode:(void(^)(BOOL alarmMode, NSError *error))completion;
- (void)exitSBandEmergencyMode:(BluetoothErrorBlock)completion;
- (void)updateSBandTime:(BluetoothErrorBlock)completion;

@end
