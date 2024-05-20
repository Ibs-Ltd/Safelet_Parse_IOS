//
//  SafeletBatteryService.m
//  Safelet
//
//  Created by Alex Motoc on 10/06/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SafeletBatteryService.h"
#import "SafeletUnit.h"

static int const kServiceUUID = 0x180F; // uuid of the service
static int const kBatteryLevelCharacteristicUUID = 0x2A19; // uuids for the characteristics
static NSString * const kBatteryLevelCharacteristicName = @"battery_level"; // the name of the characteristics

@interface SafeletBatteryService()
@end

@implementation SafeletBatteryService

- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
               serviceOffset:(int)serviceOffset {
    
    self = [super initWithName:oName
                        parent:pObj
                        baseHi:hi
                        baseLo:lo
                 serviceOffset:serviceOffset];
    
    if (self) {
        [self addBaseCharacteristic:kBatteryLevelCharacteristicName withAddress:kBatteryLevelCharacteristicUUID];
        self.battery = self.characteristicDict[kBatteryLevelCharacteristicName];
    }
    
    return self;
}

+ (int)serviceUUID {
    return kServiceUUID;
}

+ (NSString *)serviceName {
    return @"batteryLevel";
}

- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error {
    [(SafeletUnit *)self.parent handleBatteryCharacteristicNotification:yc error:error];
}

@end
