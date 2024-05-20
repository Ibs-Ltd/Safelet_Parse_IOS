//
//  FirmwareUpdateCharacteristic.m
//  Safelet
//
//  Created by Alex Motoc on 28/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "FirmwareUpdateCharacteristic.h"

static int64_t const kUUIDValueHi = 0x95503EB8F283CFB6;
static int64_t const kUUIDValueLo = 0x804554501B3E54DD;

@implementation FirmwareUpdateCharacteristic

+ (NSString *)characteristicName {
    return @"firmwareUpdate";
}

+ (yms_u128_t)characteristicUUID {
    yms_u128_t offset = {kUUIDValueHi, kUUIDValueLo};
    
    return offset;
}

- (void)writeNewFirmwareData:(NSData *)data progress:(void (^)(float))progress completion:(void (^)(NSError *))completion {
    NSUInteger location = 0;
    NSUInteger numberOfBytes = 20;
    
    @try {
        [self writeData:data fromLocation:location numberOfBytes:numberOfBytes progress:progress completion:^(NSError *error) {
            if (completion) {
                completion(error);
            }
        }];
    } @catch (NSException *exception) {
        NSLog(@"BLUETOOTH - caught exception: %@", exception);
        
        if (completion) {
            NSError *err = [NSError errorWithDomain:@"com.x2mobile.bluetooth" code:666013 userInfo:exception.userInfo];
            completion(err);
        }
    }
}

- (void)writeData:(NSData *)data
     fromLocation:(NSUInteger)location
    numberOfBytes:(NSUInteger)numberOfBytes
         progress:(void(^)(float progress))progress
       completion:(void(^)(NSError *error))completion {
    
    if (location >= data.length) {
        if (progress) {
            progress(1.0f);
        }
        
        completion(nil);
        return;
    }
    
    if (location + numberOfBytes > data.length) {
        numberOfBytes = data.length - location;
    }
    
    [self writeValue:[data subdataWithRange:NSMakeRange(location, numberOfBytes)] withBlock:^(NSError *error) {
        if (error) {
            completion(error);
            return;
        }
        
        if (progress) {
            progress((float)location / (float)data.length);
        }
        [self writeData:data fromLocation:location + numberOfBytes numberOfBytes:numberOfBytes progress:progress completion:completion];
    }];
}

@end
