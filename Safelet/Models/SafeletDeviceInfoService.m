//
//  SafeletDeviceInfoService.m
//  Safelet
//
//  Created by Alex Motoc on 30/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SafeletDeviceInfoService.h"

static int const kServiceUUID = 0x180A; // uuid of the service

// uuids for the characteristics
static int const kSystemIDCharacteristicUUID = 0x2A23;
static int const kModelNumberCharacteristicUUID = 0x2A24;
static int const kSerialNumberCharacteristicUUID = 0x2A25;
static int const kFirmwareRevisonCharacteristicUUID = 0x2A26;
static int const kHardwareRevisionCharacteristicUUID = 0x2A27;
static int const kSoftwareRevisionCharacteristicUUID = 0x2A28;
static int const kManufacturerNameCharacteristicUUID = 0x2A29;
static int const kCertificationDataCharacteristicUUID = 0x2A2A;
static int const kPnPIDCharacteristicUUID = 0x2A50;

// the name of the characteristics
static NSString * const kSystemIdCharacteristicName = @"system_id";
static NSString * const kModelNumberCharacteristicName = @"model_number";
static NSString * const kSerialNumberCharacteristicName = @"serial_number";
static NSString * const kFirmwareRevisionCharacteristicName = @"firmware_rev";
static NSString * const kHardwareRevisionCharacteristicName = @"hardware_rev";
static NSString * const kSoftwareRevisionCharacteristicName = @"software_rev";
static NSString * const kManufacturerNameCharacteristicName = @"manufacturer_name";
static NSString * const kCertificationDataCharacteristicName = @"ieee11073_cert_data";
static NSString * const kPnpIDCharacteristicName = @"pnpid_data";

@implementation SafeletDeviceInfoService

- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
               serviceOffset:(int)serviceOffset {
    
    self = [super initWithName:oName
                        parent:pObj
                        baseHi:hi
                        baseLo:lo
                 serviceOffset:serviceOffset];
    
    if (self) {
        [self addCharacteristic:kSystemIdCharacteristicName withAddress:kSystemIDCharacteristicUUID];
        [self addCharacteristic:kModelNumberCharacteristicName withAddress:kModelNumberCharacteristicUUID];
        [self addCharacteristic:kSerialNumberCharacteristicName withAddress:kSerialNumberCharacteristicUUID];
        [self addCharacteristic:kFirmwareRevisionCharacteristicName withAddress:kFirmwareRevisonCharacteristicUUID];
        [self addCharacteristic:kHardwareRevisionCharacteristicName withAddress:kHardwareRevisionCharacteristicUUID];
        [self addCharacteristic:kSoftwareRevisionCharacteristicName withAddress:kSoftwareRevisionCharacteristicUUID];
        [self addCharacteristic:kManufacturerNameCharacteristicName withAddress:kManufacturerNameCharacteristicUUID];
        [self addCharacteristic:kCertificationDataCharacteristicName withAddress:kCertificationDataCharacteristicUUID];
        [self addCharacteristic:kPnpIDCharacteristicName withAddress:kPnPIDCharacteristicUUID];
    }
    
    return self;
}

+ (NSString *)serviceName {
    return @"deviceInfo";
}

+ (int)serviceUUID {
    return kServiceUUID;
}

- (void)readDeviceInfo {
    __weak SafeletDeviceInfoService *this = self;
    
    YMSCBCharacteristic *system_idCt = self.characteristicDict[kSystemIdCharacteristicName];
    system_idCt.cbCharacteristic ? [system_idCt readValueWithBlock:^(NSData *data, NSError *error) {
        NSMutableString *tmpString = [NSMutableString stringWithFormat:@""];
        unsigned char bytes[data.length];
        [data getBytes:bytes length:data.length];
        for (int ii = (int)data.length; ii >= 0;ii--) {
            [tmpString appendFormat:@"%02hhx",bytes[ii]];
            if (ii) {
                [tmpString appendFormat:@":"];
            }
        }
        
        NSLog(@"system id: %@", tmpString);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.systemId = tmpString;
        });
        
    }] : nil;
    
    YMSCBCharacteristic *model_numberCt = self.characteristicDict[kModelNumberCharacteristicName];
    model_numberCt.cbCharacteristic ? [model_numberCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"model number: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.modelNumber = payload;
        });
    }] : nil;
    
    
    YMSCBCharacteristic *serial_numberCt = self.characteristicDict[kSerialNumberCharacteristicName];
    serial_numberCt.cbCharacteristic ? [serial_numberCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"serial number: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.serialNumber = payload;
        });
    }] : nil;
    
    
    YMSCBCharacteristic *firmware_revCt = self.characteristicDict[kFirmwareRevisionCharacteristicName];
    firmware_revCt.cbCharacteristic ? [firmware_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"firmware rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.firmwareRev = payload;
        });
    }] : nil;
    
    YMSCBCharacteristic *hardware_revCt = self.characteristicDict[kHardwareRevisionCharacteristicName];
    hardware_revCt.cbCharacteristic ? [hardware_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"hardware rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.hardwareRev = payload;
        });
    }] : nil;
    
    YMSCBCharacteristic *manufacturer_nameCt = self.characteristicDict[kManufacturerNameCharacteristicName];
    manufacturer_nameCt.cbCharacteristic ? [manufacturer_nameCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"manufacturer name: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.manufacturerName = payload;
        });
    }] : nil;
    
    YMSCBCharacteristic *software_revCt = self.characteristicDict[kSoftwareRevisionCharacteristicName];
    software_revCt.cbCharacteristic ? [software_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"software rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.softwareRev = payload;
        });
    }] : nil;
    
    YMSCBCharacteristic *ieeeCt = self.characteristicDict[kCertificationDataCharacteristicName];
    ieeeCt.cbCharacteristic ? [ieeeCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"IEEE 11073 Cert Data: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.certificationData = payload;
        });
    }] : nil;
    
    YMSCBCharacteristic *pnpId = self.characteristicDict[kPnpIDCharacteristicName];
    pnpId.cbCharacteristic ? [pnpId readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        NSLog(@"PnP ID Data: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.pnpId = payload;
        });
    }] : nil;
}

@end
