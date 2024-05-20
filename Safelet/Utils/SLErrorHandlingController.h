//
//  SLErrorHandlingController.h
//  Safelet
//
//  Created by Alex Motoc on 20/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SLErrorHandlingController : NSObject

+ (NSDictionary *)getServerErrorPayloadDictionaryFromError:(NSError *)error;
+ (void)handleError:(NSError *)error;
+ (void)handleSafeletBluetoothConnectionError;

@end
