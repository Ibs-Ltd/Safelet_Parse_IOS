//
//  EmergencyCaracteristic.m
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "EmergencyCharacteristic.h"

static int64_t const kUUIDValueHi = 0x1C52356C7D507D9B;
static int64_t const kUUIDValueLo = 0xED471D607B39650F;

@implementation EmergencyCharacteristic

+ (NSString *)characteristicName {
    return @"emergency";
}

+ (yms_u128_t)characteristicUUID {
    yms_u128_t offset = {kUUIDValueHi, kUUIDValueLo};
    
    return offset;
}

@end
