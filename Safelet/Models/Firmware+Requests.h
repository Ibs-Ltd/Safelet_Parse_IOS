//
//  Firmware+Requests.h
//  Safelet
//
//  Created by Alex Motoc on 30/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "Firmware.h"
#import "SafeletDeviceInfoService.h"

@interface Firmware (Requests)

+ (void)getLatestFirmwareForDeviceInfo:(SafeletDeviceInfoService *)service
                            completion:(void (^)(Firmware *, NSError *))completion;

@end
