#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSMutableArray+fifoQueue.h"
#import "YMS128.h"
#import "YMSCBCentralManager.h"
#import "YMSCBCharacteristic.h"
#import "YMSCBDescriptor.h"
#import "YMSCBPeripheral.h"
#import "YMSCBService.h"
#import "YMSCBStoredPeripherals.h"
#import "YMSCBUtils.h"

FOUNDATION_EXPORT double YmsCoreBluetoothVersionNumber;
FOUNDATION_EXPORT const unsigned char YmsCoreBluetoothVersionString[];

