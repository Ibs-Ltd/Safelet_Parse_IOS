//
//  SLPushNotificationManager.h
//  Safelet
//
//  Created by Alex Motoc on 18/12/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@interface SLPushNotificationManager : NSObject

NS_ASSUME_NONNULL_BEGIN
+ (instancetype)sharedManager;
- (void)handlePushNotificationDictionaryPayload:(NSDictionary *)pushNotificationDict
                                      showAlert:(BOOL)showAlert;

+ (void)registerUserForPushNotifications:(User *)user
                              completion:(void (^ _Nullable)(NSError *error))completion;
+ (void)unregisterDeviceFromNotificationsWithCompletion:(void (^ _Nullable)(NSError *error))completion;


NS_ASSUME_NONNULL_END

@end
