//
//  SafeletDeviceInfoService.h
//  Safelet
//
//  Created by Alex Motoc on 30/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseService.h"

@interface SafeletDeviceInfoService : BaseService

@property (nonatomic, strong) NSString *systemId;
@property (nonatomic, strong) NSString *modelNumber;
@property (nonatomic, strong) NSString *serialNumber;
@property (nonatomic, strong) NSString *firmwareRev;
@property (nonatomic, strong) NSString *hardwareRev;
@property (nonatomic, strong) NSString *softwareRev;
@property (nonatomic, strong) NSString *manufacturerName;
@property (nonatomic, strong) NSString *certificationData;
@property (nonatomic, strong) NSString *pnpId;
@property (nonatomic, strong) NSString *versionCode;

/**
  * Issues s set of read requests to obtain device information which will be stored in the class properties.
 */
- (void)readDeviceInfo;
+ (int)serviceUUID;

@end
