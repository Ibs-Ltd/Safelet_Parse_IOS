//
//  BaseService.m
//  Safelet
//
//  Created by Alex Motoc on 27/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseService.h"

@implementation BaseService

- (instancetype)initWithName:(NSString *)name parent:(YMSCBPeripheral *)pObj serviceUUID:(yms_u128_t)offset {
    self = [super initWithName:name
                        parent:pObj
                        baseHi:offset.hi
                        baseLo:offset.lo
                 serviceOffset:0];
    
    return self;
}

#pragma mark - Utils

- (void)addBaseCharacteristic:(NSString *)cname withAddress:(int)addr {
    BaseCharacteristic *yc;
    NSString *addrString = [NSString stringWithFormat:@"%x", addr];
    CBUUID *uuid = [CBUUID UUIDWithString:addrString];
    yc = [[BaseCharacteristic alloc] initWithName:cname
                                           parent:self.parent
                                             uuid:uuid
                                           offset:addr];
    self.characteristicDict[cname] = yc;
}

- (void)addCharacteristic:(Class)characteristic serviceUUID:(yms_u128_t)offset {
    if ([characteristic isSubclassOfClass:[BaseCharacteristic class]]) {
        NSString *characteristicName = [characteristic characteristicName];
        
        BaseCharacteristic *charact = [[characteristic alloc] initWithName:characteristicName
                                                                    parent:self.parent
                                                        characteristicUUID:[characteristic characteristicUUID]];
        
        self.characteristicDict[characteristicName] = charact;
    } else {
        NSAssert(NO, @"must add a subclass of BaseCharacteristic");
    }
}

+ (yms_u128_t)serviceUUID {
    yms_u128_t offset = {0, 0};
    
    return offset;
}

+ (NSString *)serviceName {
    return @"";
}

+ (CBUUID *)serviceCBUUID {
    return [CBUUID new];
}

@end
