//
//  RelationCharacteristic.m
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "RelationCharacteristic.h"

static int64_t const kUUIDValueHi = 0xF9AC128166E21DDE;
static int64_t const kUUIDValueLo = 0x092192B490F10A54;

@implementation RelationCharacteristic

+ (NSString *)characteristicName {
    return @"relation";
}

+ (yms_u128_t)characteristicUUID {
    yms_u128_t offset = {kUUIDValueHi, kUUIDValueLo};
    
    return offset;
}

@end
