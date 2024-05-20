//
//  MarkBluetoothConnectionFailed.m
//  Safelet
//
//  Created by Alex Motoc on 29/06/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "MarkBluetoothConnectionFailed.h"

@implementation MarkBluetoothConnectionFailed

+ (instancetype)request {
    MarkBluetoothConnectionFailed *request = [super request];
    request.showsProgressIndicator = NO;
    
    return request;
}

- (NSString *)requestURL {
    return @"markBluetoothConnectionFailed";
}

@end
