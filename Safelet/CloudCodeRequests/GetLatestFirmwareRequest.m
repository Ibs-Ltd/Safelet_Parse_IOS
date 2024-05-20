//
//  GetLatestFirmwareRequest.m
//  Safelet
//
//  Created by Alex Motoc on 30/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "GetLatestFirmwareRequest.h"

@interface GetLatestFirmwareRequest ()
@property (strong, nonatomic) SafeletDeviceInfoService *service;
@property (nonatomic) NSInteger versionCode;
@end

@implementation GetLatestFirmwareRequest

+ (instancetype)requestWithVersionCode:(NSInteger)version deviceInfo:(SafeletDeviceInfoService *)service {
    GetLatestFirmwareRequest *request = [self requestWithDeviceInfo:service];
    request.versionCode = version;
    return request;
}

+ (instancetype)requestWithDeviceInfo:(SafeletDeviceInfoService *)service {
    GetLatestFirmwareRequest *request = [self request];
    request.service = service;
    return request;
}

- (NSString *)requestURL {
    return @"getLatestFirmware";
}

- (NSDictionary *)params {
    return @{
             @"hardwareRevision":self.service.hardwareRev,
             @"model":self.service.modelNumber,
             @"versionCode":@(self.versionCode),
             @"firmwareRevision":self.service.firmwareRev
             };
}

@end
