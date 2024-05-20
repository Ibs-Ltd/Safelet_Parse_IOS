//
//  SafeletUnit+SBand.m
//  Safelet
//
//  Created by Alexandru Motoc on 12/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SafeletUnit+SBand.h"
#import "SafeletUnitManager.h"
#import "NSException+NSError.h"
#import <UIKit/UIKit.h>

typedef void(^WorkBlock)(BluetoothErrorBlock workCompletion);

@implementation SafeletUnit (SBand)

#pragma mark - logic

- (void)removeSBandRelation:(void (^)(NSError *))completion {
    [self reset:^(NSError * _Nonnull error) {
        if (error) {
            completion == nil ?: completion(error);
            return;
        }
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConnectedSafeletIdentifierKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        completion == nil ?: completion(error);
    }];
}

- (void)confirmSBandDispatchAlarm:(void (^)(NSError *))completion {
    @try {
        [self showTextOnDisplay:NSLocalizedString(@"Alarm sent to guardians", nil) completion:completion vibrate:YES];
    } @catch (NSException *ex) {
        NSLog(@"BLUETOOTH - caught exception: %@", ex);
        completion == nil ?: completion([ex toError]);
    }
}

- (void)confirmSBandJoinAlarmWithUserName:(NSString *)userName completion:(BluetoothErrorBlock)completion {
    @try {
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"%@ is on his way", nil), userName];
        [self showTextOnDisplay:msg completion:completion vibrate:YES];
    } @catch (NSException *ex) {
        NSLog(@"BLUETOOTH - caught exception: %@", ex);
        completion == nil ?: completion([ex toError]);
    }
}

- (void)exitSBandEmergencyMode:(void (^)(NSError *))completion {
    @try {
        [self.sbandBLE.buttonCharacteristic writeByte:0x00 withBlock:^(NSError *error) {
            completion == nil ?: completion(error);
        }];
    } @catch (NSException *ex) {
        NSLog(@"BLUETOOTH - caught exception: %@", ex);
        completion == nil ?: completion([ex toError]);
    }
}

- (void)checkSBandEmergencyMode:(void (^)(BOOL, NSError *))completion {
    @try {
        [self.sbandBLE.buttonCharacteristic readIntegerValue:^(NSInteger value, NSError *error) {
            completion == nil ?: completion(value > 0, error);
        }];
    } @catch (NSException *exception) {
        NSLog(@"BLUETOOTH - caught exception: %@", exception);
        completion(NO, [exception toError]);
    }
}

- (void)updateSBandTime:(BluetoothErrorBlock)completion {
    NSDate *sourceDate = [NSDate date];
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:sourceDate];
    int32_t timestamp = [destinationDate timeIntervalSince1970];
    NSData *data = [NSData dataWithBytes:&timestamp length:sizeof(timestamp)];
    @try {
        [self.sbandBLE.rTCSyncCharacteristic writeValue:data withBlock:^(NSError *error) {
            completion == nil ?: completion(error);
        }];
    } @catch (NSException *ex) {
        NSLog(@"BLUETOOTH - caught exception: %@", ex);
        completion == nil ?: completion([ex toError]);
    }
}

#pragma mark - utils

- (void)showTextOnDisplay:(NSString *)text completion:(BluetoothErrorBlock)completion vibrate:(BOOL)vibrate {
    const NSInteger kMaxLength = 20; // 20 bytes
    NSArray <NSString *> *words = [text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSInteger length1 = 0;
    NSInteger length2 = 0;
    NSString *displayText1 = @"";
    NSString *displayText2 = @"";
    for (NSString *word in words) {
        NSString *format = @" %@";
        NSInteger wlen = word.length + 1;
        
        if (length1 + wlen > kMaxLength) {
            if (length2 + wlen > kMaxLength) {
                break;
            }
            
            if (displayText2.length == 0) {
                format = @"%@";
                wlen -= 1;
            }
            displayText2 = [displayText2 stringByAppendingFormat:format, word];
            length2 += wlen;
            continue;
        }
        
        if (displayText1.length == 0) {
            format = @"%@";
            wlen -= 1;
        }
        displayText1 = [displayText1 stringByAppendingFormat:format, word];
        length1 += wlen;
    }
    
    WorkBlock vibrateBlock = nil;
    if (vibrate) {
        vibrateBlock = ^void(BluetoothErrorBlock workCompletion) {
            [self.sbandBLE.vibrationControlCharacteristic writeByte:0x01 withBlock:workCompletion];
        };
    }
    
    [self handleWorkBlocksWithCompletion:completion
                                  blocks:^(BluetoothErrorBlock workCompletion) {
                                      [self.sbandBLE.textCharacteristic1 writeValue:[displayText1 dataUsingEncoding:NSUTF8StringEncoding]
                                                                          withBlock:workCompletion];
                                  }, ^(BluetoothErrorBlock workCompletion) {
                                      [self.sbandBLE.textCharacteristic2 writeValue:[displayText2 dataUsingEncoding:NSUTF8StringEncoding]
                                                                          withBlock:workCompletion];
                                  }, ^(BluetoothErrorBlock workCompletion) {
                                      [self.sbandBLE.displayCharacteristic writeByte:0x0A
                                                                           withBlock:workCompletion];
                                  }, vibrateBlock, nil];
}

// will call blocks in a serial way
- (void)handleWorkBlocksWithCompletion:(BluetoothErrorBlock)completion blocks:(WorkBlock)firstObj, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray <WorkBlock> *blocks = [NSMutableArray array];
    va_list args;
    
    [blocks addObject:firstObj];
    
    va_start(args, firstObj);
    WorkBlock arg = nil;
    while ((arg = va_arg(args, WorkBlock))) {
        [blocks addObject:arg];
    }
    va_end(args);
    
    [self executeSerialBlocks:blocks currentIndex:0 completion:completion];
}

- (void)executeSerialBlocks:(NSArray <WorkBlock> *)blocks
               currentIndex:(NSInteger)index
                 completion:(BluetoothErrorBlock)completion {
    if (index == blocks.count) {
        completion == nil ?: completion(nil);
        return;
    }
    blocks[index](^void(NSError *error) {
        if (error) {
            completion == nil ?: completion(error);
            return;
        }
        
        [self executeSerialBlocks:blocks currentIndex:index + 1 completion:completion];
    });
}

@end
