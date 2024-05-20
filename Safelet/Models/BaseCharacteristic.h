//
//  BaseCharacteristic.h
//  Safelet
//
//  Created by Alex Motoc on 27/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <YmsCoreBluetooth/YMSCBCharacteristic.h>

@interface BaseCharacteristic : YMSCBCharacteristic

/**
 *  Convenience init
 *
 *  @param name   name of characteristic to be created
 *  @param pObj   the parent peripheral
 *  @param offset the UUID offset (2 halves of 64 bit values => 12 bit uuid)
 *
 *  @return the constructed object
 */
- (instancetype)initWithName:(NSString *)name parent:(YMSCBPeripheral *)pObj characteristicUUID:(yms_u128_t)offset;

/**
 *  This is actually the entire UUID of the service; it is the "base", it has the "serviceOffset" included
 *
 *  @return the UUID split in 2 hexadecimal halves (hi and lo)
 */
+ (yms_u128_t)characteristicUUID;
+ (NSString *)characteristicName;

/**
 *  Convenience getter that reads the NSData value from the characteristic and converts it into an integer
 *
 *  @param completion completion block
 *         - value => the integer value obtained
 *         - error => the encountered error if any
 */
- (void)readIntegerValue:(void(^)(NSInteger value, NSError *error))completion;
- (void)readStringValue:(void(^)(NSString *value, NSError *error))completion;

@end
