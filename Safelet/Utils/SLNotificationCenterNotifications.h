//
//  SLNotificationCenterNotifications.h
//  Safelet
//
//  Created by Alex Motoc on 17/12/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#ifndef SLNotificationCenterNotifications_h
#define SLNotificationCenterNotifications_h

// notification sent when a view controller that displays information should fetch it again from the server (i.e. refresh with new content)
//static NSString * const SLFetchNewDataNotification = @"fetchData";
// notification sent when SLPushNotificationManager finished handling a notification (added new data from that notification)
//static NSString * const SLRefreshUINotification = @"refreshUI";

static NSString * const SLBraceletBatteryChangedNotification = @"batteryChanged";

static NSString * const SLBluetoothStateChangedNotification = @"bluetoothStateChanged";

static NSString * const SLReloadDataNotification = @"reloadData";

static NSString * const SLAlarmChatHasContentNotification = @"chatHasContent"; // dispatched only once when we discover the alarm chat has existing meesages

static NSString * const SLUserPolicyNotification = @"userPolicy";

static NSString * const SLUserProfileNotification = @"useProfileUpdated";

#endif /* SLNotificationCenterNotifications_h */
