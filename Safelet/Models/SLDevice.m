//
//  SLDevice.m
//  Safelet
//
//  Created by Alex Motoc on 27/03/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SLDevice.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

@implementation SLDevice

+ (instancetype)currentDevice {
    static SLDevice *device;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        device = [self new];
        
        UIDevice *currentDevice = [UIDevice currentDevice];
        device.name = currentDevice.model;
        device.model = deviceModel();
        device.osVersion = [NSString stringWithFormat:@"%@ %@", currentDevice.systemName, currentDevice.systemVersion];
    });
    
    return device;
}

NSString* deviceModel() {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

@end
