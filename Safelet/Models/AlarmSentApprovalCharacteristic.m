//
//  AlarmSentApprovalCharacteristic.m
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "AlarmSentApprovalCharacteristic.h"

static int64_t const kUUIDValueHi = 0xE34369EEFCAB11E5;
static int64_t const kUUIDValueLo = 0x86AA5E5517507C66;

@implementation AlarmSentApprovalCharacteristic

+ (NSString *)characteristicName {
    return @"alarmSentApproval";
}

+ (yms_u128_t)characteristicUUID {
    yms_u128_t offset = {kUUIDValueHi, kUUIDValueLo};
    
    return offset;
}

@end
