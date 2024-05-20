//
//  LEDControlCharacteristic.m
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "LEDControlCharacteristic.h"

static int64_t const kUUIDValueHi = 0xFD692F725639C3A8;
static int64_t const kUUIDValueLo = 0x6F483E7236C36D05;

@implementation LEDControlCharacteristic

+ (NSString *)characteristicName {
    return @"ledControl";
}

+ (yms_u128_t)characteristicUUID {
    yms_u128_t offset = {kUUIDValueHi, kUUIDValueLo};
    
    return offset;
}

@end
