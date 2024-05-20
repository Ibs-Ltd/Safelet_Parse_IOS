//
//  SLError.h
//  Safelet
//
//  Created by Alex Motoc on 05/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const SLSafeletErrorDomain = @"com.x2mobile.Safelet";

typedef NS_ENUM(NSInteger, SLErrorCode) {
    SLErrorCodeNoContactsPermission = -6999, // error code for "No permission to Contacts"
    SLErrorCodeInvalidSafeletMode = -7000,
    SLErrorCodeFailedToConnectSafelet = -7001,
    SLErrorCodeMissingPushNotificationData = -7002,
    SLErrorCodeBluetoothException = -7003
};

@interface SLError : NSObject

+ (NSError *)errorWithCode:(SLErrorCode)code failureReason:(NSString *)failure;

@end
