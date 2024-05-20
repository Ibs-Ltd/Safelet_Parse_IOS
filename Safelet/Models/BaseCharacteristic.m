//
//  BaseCharacteristic.m
//  Safelet
//
//  Created by Alex Motoc on 27/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseCharacteristic.h"
#import <YmsCoreBluetooth/YMSCBUtils.h>

@implementation BaseCharacteristic

- (instancetype)initWithName:(NSString *)name parent:(YMSCBPeripheral *)pObj characteristicUUID:(yms_u128_t)offset {
    self = [super initWithName:name
                        parent:pObj
                        uuid:[YMSCBUtils createCBUUID:&offset withIntOffset:0]
                        offset:0];
    
    return self;
}

+ (yms_u128_t)characteristicUUID {
    yms_u128_t offset = {0, 0};
    
    return offset;
}

+ (NSString *)characteristicName {
    return @"";
}

- (void)readIntegerValue:(void (^)(NSInteger, NSError *))completion {
    [self readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            completion == nil ?: completion(0, error);
            return;
        }
        
        NSInteger decodedInteger = [YMSCBUtils dataToByte:data];
        
        if (completion) {
            _YMS_PERFORM_ON_MAIN_THREAD(^{
                completion(decodedInteger, nil);
            });
        }
    }];
}

- (void)readStringValue:(void (^)(NSString *, NSError *))completion {
    [self readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            completion == nil ?: completion(nil, error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        
        if (completion) {
            _YMS_PERFORM_ON_MAIN_THREAD(^{
                completion(payload, nil);
            });
        }
    }];
}

@end
