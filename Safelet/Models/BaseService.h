//
//  BaseService.h
//  Safelet
//
//  Created by Alex Motoc on 27/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseCharacteristic.h"
#import <YmsCoreBluetooth/YMSCBService.h>
#import <YmsCoreBluetooth/YMS128.h>

@interface BaseService : YMSCBService

/**
 *  Convenience init
 *
 *  @param name   name of service to be created
 *  @param pObj   the parent peripheral
 *  @param offset the UUID offset (ony base - 2 halves of 64 bit values => 128 bit uuid)
 *
 *  @return the constructed object
 */
- (instancetype)initWithName:(NSString *)name parent:(YMSCBPeripheral *)pObj serviceUUID:(yms_u128_t)offset;

/**
 *  Adds a characteristic to the service
 *  IMPORTANT: The class provided for the characteristic must be a subclass of BaseCharacteristic;
 *       otherwise, the characteristic will not be added
 *
 *  @param characteristic the class of the characteristic we want to add (subclass of BaseCharacteristic)
 *  @param offset         the UUID offset (base)
 */
- (void)addCharacteristic:(Class)characteristic serviceUUID:(yms_u128_t)offset;

- (void)addBaseCharacteristic:(NSString *)cname withAddress:(int)addr;

/**
 *  This is actually the entire UUID of the service; it is the "base", it has the "serviceOffset" included
 *
 *  @return the UUID split in 2 hexadecimal halves (hi and lo)
 */
+ (yms_u128_t)serviceUUID;
+ (CBUUID *)serviceCBUUID;
+ (NSString *)serviceName;

@end
