//
//  SBandDFUController.m
//  Safelet
//
//  Created by Alexandru Motoc on 18/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SBandDFUController.h"
#import "SafeletUnitManager.h"

static NSString * const kDFUPeripheralName = @"sbandDFU";

@interface SBandDFUController()
@property (copy, nonatomic) FirmwareProgress firmwareProgress;
@property (copy, nonatomic) BluetoothErrorBlock firmwareCompletion;
@property (strong, nonatomic) SafeletUnit *dfuSafelet;
@end

@implementation SBandDFUController

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static SBandDFUController *manager;
    dispatch_once(&onceToken, ^{
        manager = [SBandDFUController new];
    });
    return manager;
}

// sets SafeletUnit mode to 5
// scans for sbandDFU and returns it back once found
- (void)setSafeletToDFU:(SafeletUnit *)safelet completion:(void(^)(SafeletUnit *dfuSafelet, NSError *error))completion {
    SafeletUnitManager *manager = [SafeletUnitManager shared];
    manager.dfuInProgress = YES;
    
    [safelet.sbandBLE.modeCharacteristic writeByte:SafeletUnitModeImageUPD withBlock:^(NSError *error) {
        NSLog(@"DFU RESET");
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // wait one second for the device to enter DFU mode
        [manager scanForPeripheralsWithServices:SafeletUnit.safeletServices
                                        options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @NO }
                                      withBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
                                          NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
                                          NSLog(@"DFU: %@, %@, %@ db; local name: %@", peripheral, peripheral.name, RSSI, localName);
                                          
                                          if ([peripheral.name isEqualToString:kDFUPeripheralName] ||
                                              [localName isEqualToString:kDFUPeripheralName]) {
                                              
                                              SafeletUnit *dfuSafelet = [[SafeletUnit alloc] initWithPeripheral:peripheral
                                                                                                        central:manager
                                                                                                         baseHi:0
                                                                                                         baseLo:0];
                                              [manager stopScan];
                                              self.dfuSafelet = dfuSafelet;
                                              completion(dfuSafelet, nil);
                                          }
                                      }];
    });
}

- (void)updateSBand:(SafeletUnit *)safelet
           firmware:(Firmware *)firmware
           progress:(void (^)(float, FirmwareUpdateProgressType))progressBlock
         completion:(void (^)(NSError *))completion {
    if (completion == nil) {
        return;
    }
    
    self.firmwareProgress = progressBlock;
    self.firmwareCompletion = completion;
    
    [firmware.updatefile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error) {
            completion(error);
            return;
        }
        
        progressBlock(0, FirmwareUpdateProgressTypeResetting);
        
        __weak typeof(self) this = self;
        [self setSafeletToDFU:safelet completion:^(SafeletUnit *dfuSafelet, NSError *error) {
            DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithZipFile:data];
            DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:dfuSafelet.central.manager
                                                                                          target:dfuSafelet.cbPeripheral];
            
            (void)[initiator withFirmware:selectedFirmware];
            initiator.delegate = this;
            initiator.logger = this;
            initiator.progressDelegate = this;
            (void)[initiator start];
        }];
    } progressBlock:^(int percentDone) {
        progressBlock((float)percentDone / 100.0f, FirmwareUpdateProgressTypeDownloading);
    }];
}

#pragma mark - DFUServiceDelegate

- (void)dfuStateDidChangeTo:(enum DFUState)state {
    if (state == DFUStateCompleted) {
        [self.dfuSafelet disconnect];
        
        self.firmwareProgress(0, FirmwareUpdateProgressTypeResetting);
        SafeletUnitManager *manager = [SafeletUnitManager shared];
        [manager resetCBCentralManager:^(NSError *error) {
            manager.dfuInProgress = NO;
            self.firmwareCompletion(error);
            self.firmwareCompletion = nil;
            self.firmwareProgress = nil;
        }];
    }
    NSLog(@"DFU - state %ld", (long)state);
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString *)message {
    NSLog(@"DFU - error: %ld, message: %@", (long)error, message);
    self.firmwareCompletion([NSError errorWithDomain:@"com.safelet.dfuerror"
                                                code:error
                                            userInfo:@{NSLocalizedDescriptionKey:message}]);
    self.firmwareCompletion = nil;
    self.firmwareProgress = nil;
}

#pragma mark - DFUProgressDelegate

- (void)dfuProgressDidChangeFor:(NSInteger)part
                          outOf:(NSInteger)totalParts
                             to:(NSInteger)progress
     currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond
         avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    self.firmwareProgress((float)progress / 100.0f, FirmwareUpdateProgressTypeInstalling);
}

#pragma mark - LoggerDelegate

- (void)logWith:(enum LogLevel)level message:(NSString *)message {
    NSLog(@"DFU log %ld - %@", (long)level, message);
}

@end

