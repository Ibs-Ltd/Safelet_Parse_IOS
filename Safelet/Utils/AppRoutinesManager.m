//
//  AppRoutinesManager.m
//  Safelet
//
//  Created by Alex Motoc on 23/05/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "AppRoutinesManager.h"
#import "User.h"
#import "SavePhoneDetailsRequest.h"
#import "SLDataManager.h"
#import "SLUserDefaults.h"
#import "SLPushNotificationManager.h"
#import "SLLocationManager.h"
#import "SafeletUnitManager.h"
#import "SLAlarmManager.h"
#import "SlideMenuMainViewController.h"
#import "GetFirebaseAuthTokenRequest.h"
#import "SLErrorHandlingController.h"

@import FirebaseAuth;

@implementation AppRoutinesManager

+ (void)startSafeletRoutinesForUser:(User *)user {
    [[SavePhoneDetailsRequest request] runRequest];
    
    [[SLDataManager sharedManager] syncContactsListWithCompletion:nil];
    
    [self firebaseLogin];
    
    // needed to complete the email field if the user logs out
    // this way he can re-log in quickly, having to only provide his password
    [SLUserDefaults setPreviouslyUsedEmail:user.email];
    
    [SLPushNotificationManager registerUserForPushNotifications:user completion:nil];
    
    [[SLLocationManager sharedManager] setupNormalLocationTracking];
    
    [SafeletUnitManager shared];
}

+ (void)startSafeletRoutinesWithoutUser {
    [SafeletUnitManager shared];
}

+ (void)startRoutinesForAppEnteredBackground {
    [[SLDataManager sharedManager] clearCachedData];
}

+ (void)startRoutinesForAppEnteredForeground {
    [self clearNotifications:[UIApplication sharedApplication]];
    
    [[SLDataManager sharedManager] syncContactsListWithCompletion:nil];
    
    // set alarm screen visible if an alarm is dispatched by the current user
    SLAlarmManager *alarmManager = [SLAlarmManager sharedManager];
    if (alarmManager.alarm.isActive) {
        SlideMenuMainViewController *menuViewController = [SlideMenuMainViewController currentMenu];
        [menuViewController.leftMenu performSegueWithIdentifier:menuViewController.alarmSegueIdentifier
                                                         sender:nil];
    }
}

#pragma mark - Utils

+ (void)clearNotifications:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}

+ (void)firebaseLogin {
    GetFirebaseAuthTokenRequest *request = [GetFirebaseAuthTokenRequest request];
    [request setRequestCompletionBlock:^(NSString * _Nullable response, NSError * _Nullable error) {
        if (error) {
            [SLErrorHandlingController handleError:error];
            return;
        }
        
        [[FIRAuth auth] signInWithCustomToken:response
                                   completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                                       
                                   }];
    }];
    [request runRequest];
}

@end
