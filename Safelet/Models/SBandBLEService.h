//
//  SBandBLEService.h
//  Safelet
//
//  Created by Alexandru Motoc on 10/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "BaseService.h"

@interface SBandBLEService : BaseService

@property (strong, nonatomic) BaseCharacteristic *modeCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *relationCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *buttonCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *vibrationControlCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *vibrationPeriodCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *batteryPercentageCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *batteryStatusCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *stepCounterCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *textCharacteristic1;
@property (strong, nonatomic) BaseCharacteristic *textCharacteristic2;
@property (strong, nonatomic) BaseCharacteristic *displayCharacteristic;
@property (strong, nonatomic) BaseCharacteristic *rTCSyncCharacteristic;

@end
