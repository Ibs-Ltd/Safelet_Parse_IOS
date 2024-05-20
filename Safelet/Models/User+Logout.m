//
//  User+Logout.m
//  Safelet
//
//  Created by Alex Motoc on 20/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "User+Logout.h"
#import "SLLocationManager.h"
#import "SLAlarmManager.h"
#import "LoginViewController.h"
#import "SLErrorHandlingController.h"
#import "SLDataManager.h"
#import "SLAlarmRecordingManager.h"
#import "SlideMenuMainViewController.h"
#import "SLPushNotificationManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@import FirebaseAuth;

static NSString * const kRootNavigationControllerID = @"rootNavigationController";

@implementation User (Logout)

+ (void)logoutAndShowLoginScreen {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    
    if (!status) {
        [MBProgressHUD hideHUDForView:window animated:YES];
        [SLErrorHandlingController handleError:signOutError];
        return;
    }
    
    //clear any registered channels for this device (if token is available), since no user is logged in
    [SLPushNotificationManager unregisterDeviceFromNotificationsWithCompletion:^(NSError * _Nonnull error) {
        if (error) {
            [SLErrorHandlingController handleError:error];
            return;
        }
        
        [User logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:window animated:YES];
            if (error) {
                [SLErrorHandlingController handleError:error];
            } else {
                [self performLogoutActions];
            }
        }];
    }];
}

#pragma mark - Utils

+ (void)performLogoutActions {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    NSString *mainStoryboardName = [[NSBundle mainBundle].infoDictionary objectForKey:@"UIMainStoryboardFile"];
    
    // must clear cached only lastly, because other managers use it
    [[SLDataManager sharedManager] clearCachedData];
    if ([SLAlarmManager sharedManager].alarm) {
        [SLAlarmManager handleStopAlarm];
    }
    
    [[SLLocationManager sharedManager] stopMonitoringLocation]; // also disable the location manager
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:mainStoryboardName bundle:nil];
    UIViewController *root = [storyboard instantiateViewControllerWithIdentifier:kRootNavigationControllerID];
    [UIView transitionWithView:window
                      duration:0.3f
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ window.rootViewController = root; }
                    completion:^(BOOL finished) {
                        SlideMenuMainViewController __strong *menu = [SlideMenuMainViewController currentMenu];
                        [menu.currentActiveNVC setViewControllers:@[] animated:NO];
                        menu.currentActiveNVC = nil;
                        menu.leftMenu = nil;
                        menu = nil;
                    }];
}

@end

