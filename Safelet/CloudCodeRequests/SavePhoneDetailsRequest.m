//
//  SavePhoneDetailsRequest.m
//  Safelet
//
//  Created by Alex Motoc on 22/06/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SLDevice.h"
#import "SavePhoneDetailsRequest.h"

@implementation SavePhoneDetailsRequest

+ (instancetype)request {
    SavePhoneDetailsRequest *request = [super request];
    request.showsProgressIndicator = NO;
    return request;
}

- (NSString *)requestURL {
    return @"savePhoneDetails";
}

- (NSDictionary *)params {
    return @{
             @"device":[SLDevice currentDevice].name,
             @"model":[SLDevice currentDevice].model,
             @"osVersion":[SLDevice currentDevice].osVersion,
             };
}

@end
