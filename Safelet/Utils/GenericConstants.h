//
//  GenericConstants.h
//  Safelet
//
//  Created by Alex Motoc on 09/06/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef GenericConstants_h
#define GenericConstants_h

typedef NS_ENUM(NSInteger, BluetoothConnectionStatus) {
    BluetoothConnectionStatusNoSafeletRelation,
    BluetoothConnectionStatusPoweredOff,
    BluetoothConnectionStatusUnauthorized,
    BluetoothConnectionStatusUnsupported,
    BluetoothConnectionStatusDisconnected,
    BluetoothConnectionStatusConnected,
};

typedef NS_ENUM(NSInteger, EventContentType) {
    EventContentTypeAlarms,
    EventContentTypeInvitations,
    EventContentTypeCheckIns
};

/**
 *  These are all the possible content options the user can choose from when opening the menu.
 *  IMPORTANT NOTE: This enum must be in the exact order as the menu cells (options) are listed
 *      Therefore, if you switch the order of the menu items, you must switch the order of this enum list
 */
typedef NS_ENUM(NSUInteger, SLContentType) {
    SLContentTypeHome,
    SLContentTypeMyProfile,
    SLContentTypeMyConnections,
    SLContentTypeEvents,
    SLContentTypeFeedback,
    SLContentTypeOptions,
    SLContentTypeLogOut,
    SLContentTypeGuardianNetwork,
    SLContentTypeConnectSafelet,
    SLContentTypeCheckIn,
    SLContentTypeGettingStarted,
    SLContentTypeAlarm
    
    
};

#endif /* GenericConstants_h */
