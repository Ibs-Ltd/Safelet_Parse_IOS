//
//  GetLatestFirmwareRequest.h
//  Safelet
//
//  Created by Alex Motoc on 30/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"
#import "SafeletDeviceInfoService.h"

@interface GetLatestFirmwareRequest : BaseRequest

+ (instancetype)requestWithVersionCode:(NSInteger)version deviceInfo:(SafeletDeviceInfoService *)service;
+ (instancetype)requestWithDeviceInfo:(SafeletDeviceInfoService *)service;

@end
