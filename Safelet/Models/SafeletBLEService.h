//
//  SafeletBLEService.h
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseService.h"
#import "ModeCharacteristic.h"
#import "RelationCharacteristic.h"
#import "EmergencyCharacteristic.h"
#import "LEDControlCharacteristic.h"
#import "FirmwareUpdateCharacteristic.h"
#import "AlarmSentApprovalCharacteristic.h"

@interface SafeletBLEService : BaseService

@property (strong, nonatomic, readonly) ModeCharacteristic *mode;
@property (strong, nonatomic, readonly) RelationCharacteristic *relation;
@property (strong, nonatomic, readonly) EmergencyCharacteristic *emergency;
@property (strong, nonatomic, readonly) LEDControlCharacteristic *ledControl;
@property (strong, nonatomic, readonly) FirmwareUpdateCharacteristic *firmwareUpdate;
@property (strong, nonatomic, readonly) AlarmSentApprovalCharacteristic *alarmSentApproval;

@end
