//
//  Firmware+Requests.m
//  Safelet
//
//  Created by Alex Motoc on 30/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "Firmware+Requests.h"
#import "SafeletUnitManager.h"
#import "GetLatestFirmwareRequest.h"

@implementation Firmware (Requests)

+ (void)getLatestFirmwareForDeviceInfo:(SafeletDeviceInfoService *)service
                            completion:(void (^)(Firmware *, NSError *))completion {
    if ([service.modelNumber.lowercaseString isEqualToString:@"safelet"]) {
        [[SafeletUnitManager shared].safeletPeripheral.safeletBLE.firmwareUpdate readIntegerValue:^(NSInteger value, NSError *error) {
            GetLatestFirmwareRequest *request = [GetLatestFirmwareRequest requestWithVersionCode:value deviceInfo:service];
            [request setRequestCompletionBlock:completion];
            [request runRequest];
        }];
    } else {
        GetLatestFirmwareRequest *request = [GetLatestFirmwareRequest requestWithDeviceInfo:service];
        [request setRequestCompletionBlock:completion];
        [request runRequest];
    }
}

@end
