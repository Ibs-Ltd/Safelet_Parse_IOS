//
//  SLDevice.h
//  Safelet
//
//  Created by Alex Motoc on 27/03/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLDevice : NSObject

+ (instancetype)currentDevice;

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *osVersion;

@end
