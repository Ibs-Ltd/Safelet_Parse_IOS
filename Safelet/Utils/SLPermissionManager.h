//
//  SLPermissionManager.h
//  Safelet
//
//  Created by Alex Motoc on 16/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLPermissionManager : NSObject

/**
 *  Requests permission to access mic. If already granted, do nothing.
 *  If not granted, show an error message and request user to enable
 */
+ (void)requestMicrophonePermission;

@end
