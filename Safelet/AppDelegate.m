//
//  AppDelegate.m
//  Safelet
//
//  Created by Alex Motoc on 28/09/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "AppDelegate.h"
#import "User+Requests.h"
#import "SLLocationManager.h"
#import "SLAlarmManager.h"
#import "SLDataManager.h"
#import "Utils.h"
#import "SLPushNotificationManager.h"
#import "EventsTableViewController.h"
#import "SlideMenuMainViewController.h"
#import "LeftMenuTableViewController.h"
#import "SafeletUnitManager.h"
#import "SLErrorHandlingController.h"
#import "AppVersionManager.h"
#import "AppRoutinesManager.h"
#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>
#import <UserNotifications/UserNotifications.h>
//#import <Fabric/Fabric.h>
//#import <Crashlytics/Crashlytics.h>
#import <GoogleMaps/GoogleMaps.h>

@import Firebase;

static NSString * const kLoadScreenViewControllerStoryboardID = @"loadScreenStoryboardID";
static NSString * const kLoadScreenStoryboardName = @"LoadScreen";
static NSString * const kMainStoryboardName = @"Main";

// parse-server constants
static NSString * const kParseServerURL_local = @"http://localhost:8080/parse";
static NSString * const kParseServerURL_dev = @"https://safelet-dev.herokuapp.com/parse";
//https://safelet-test-dev2.herokuapp.com/parse
static NSString * const kParseServerURL_staging = @"https://safelet-staging.herokuapp.com/parse";
static NSString * const kParseServerURL_release = @"https://safelet.herokuapp.com/parse";

static NSString * const kParseServerAppId_dev = @"Zb1Ae576LVwLcHsGWc6hYOvwNc2Z3YS6xqOQEZ7n";
static NSString * const kParseServerAppId_release = @"zLhpwZUZbSiEc4hcQso5TGTyTKBJe2u3ktQSiqma";

@interface AppDelegate () <UNUserNotificationCenterDelegate>
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self clearNotifications:application];
    [self registerForPushNotifications];
    [SLDataManager sharedManager];
    [GMSServices provideAPIKey:@"AIzaSyCNR2A9M4MyUDMA8zD_v7dvFqZmtGTiUbc"];
    [FIRApp configure];
    
//        NSString *appId = kParseServerAppId_dev;
//        NSString *server = kParseServerURL_dev;
    
    NSString *appId = kParseServerAppId_release;
    NSString *server = kParseServerURL_release;
    
#ifdef DEBUG
//    appId = kParseServerAppId_dev;
//    server = kParseServerURL_dev;
        appId = kParseServerAppId_release;
        server = kParseServerURL_release;
#endif
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        configuration.localDatastoreEnabled = YES;
        configuration.applicationId = appId;
        configuration.server = server;
    }]];
    
    // app is woken due to significant location changes
    if ([launchOptions[UIApplicationLaunchOptionsLocationKey] boolValue]) {
        [[SLLocationManager sharedManager] setupNormalLocationTracking];
    }
    
    if ([User currentUser]) { // if the user didn't sign out
        [self setContentViewController:launchOptions];
    } else {
        [AppRoutinesManager startSafeletRoutinesWithoutUser];
    }
    
    // MUST BE LAST LINE
    //    [Fabric with:@[[Crashlytics class]]];
    [[AppVersionManager sharedManager] checkForLatestAppVersion];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [AppRoutinesManager startRoutinesForAppEnteredBackground];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [AppRoutinesManager startRoutinesForAppEnteredForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // start the normal location tracking, which will work even in the app is terminated.
    // the Alarm Mode location tracking only works while the app is in background, not when it's terminated
    [[SLLocationManager sharedManager] setupNormalLocationTracking];
}

#pragma mark - Remote with User Notifications delegate
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary *userInfo = notification.request.content.userInfo;
    BOOL showAlert = YES;
    NSLog(@"%@", userInfo);
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        // opened from a push notification when the app was on background
        // in this case, don't show alert view
        showAlert = NO;
    }
    
    [[SLPushNotificationManager sharedManager] handlePushNotificationDictionaryPayload:userInfo
                                                                             showAlert:YES];
    
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
    //completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    
    NSLog(@"%@", userInfo);
    UIApplication *application = [UIApplication sharedApplication];
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        // opened from a push notification when the app was on background
        // in this case, don't show alert view
        [[SLPushNotificationManager sharedManager] handlePushNotificationDictionaryPayload:userInfo
                                                                                 showAlert:YES];
    }
    
    
    
    completionHandler();
}

#pragma mark - Remote notifications delegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (![User currentUser]) { // user has logged out
        currentInstallation.channels = @[];
    } else {
        currentInstallation.channels = @[[User currentUser].objectId];
    }
    
    [currentInstallation setDeviceTokenFromData:deviceToken];
    NSLog(@"token:%@",[self stringWithDeviceToken:deviceToken]);
    [currentInstallation saveInBackground];
}

- (NSString *)stringWithDeviceToken:(NSData *)deviceToken {
    const char *data = [deviceToken bytes];
    NSMutableString *token = [NSMutableString string];

    for (NSUInteger i = 0; i < [deviceToken length]; i++) {
        [token appendFormat:@"%02.2hhX", data[i]];
    }

    return [token copy];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [UIAlertController showErrorAlertWithMessage:[error localizedDescription]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    BOOL showAlert = YES; // default value; show alert when the app is in foreground
    NSLog(@"%@",userInfo);
    if (application.applicationState == UIApplicationStateInactive || application.applicationState == UIApplicationStateBackground) {
        // opened from a push notification when the app was on background
        // in this case, don't show alert view
        showAlert = NO;
    }
    
    [[SLPushNotificationManager sharedManager] handlePushNotificationDictionaryPayload:userInfo
                                                                             showAlert:showAlert];
    
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [UIAlertController showAlertWithTitle:notification.alertTitle message:notification.alertBody];
}

#pragma mark - Utils

- (void)clearNotifications:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
}

- (void)registerForPushNotifications {
    if ([UNUserNotificationCenter class] != nil) {
        // iOS 10 or later
        // For iOS 10 display notification (sent via APNS)
        [UNUserNotificationCenter currentNotificationCenter].delegate = self;
        UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
        UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
        [[UNUserNotificationCenter currentNotificationCenter]
         requestAuthorizationWithOptions:authOptions
         completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // ...
        }];
    } else {
        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

/**
 *	Before setting the initial view, present a loading screen, identical to the splashscreen,
 *  in order to download any additional required data.
 *
 *  This method verifies if the app was launched from a push notification and shows a relevant screen in that case
 *  Otherwise, just show the main menu view controller
 *
 *	@param launchOptions	NSDictionary * containing the app launch opttions (the one from didFinishLaunchingWithOptions)
 */
- (void)setContentViewController:(NSDictionary *)launchOptions {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kLoadScreenStoryboardName
                                                         bundle:nil];
    
    UIViewController *launchVC = [storyboard instantiateViewControllerWithIdentifier:kLoadScreenViewControllerStoryboardID];
    self.window.rootViewController = launchVC;
    
    // get the active alarm for the current user (if any)
    [SLAlarmManager getAlarmForUser:[User currentUser]
                         completion:^(Alarm *alarm, NSError *error) {
        if (error) {
            [SLErrorHandlingController handleError:error];
            // if error we continue execution, because we need to go to the next screen
        }
        
        // must init bluetooth after the pre-loading finishes, because it may also change the UI
        // must init first because [SLAlarmManager handleStopAlarm] will access the shared service, and it musn't be nil
        [SafeletUnitManager shared];
        
        if (alarm) { // if there is an active alarm for the provided user, setup Alarm Mode
            [SLAlarmManager handleDispatchAlarm:alarm shouldPlaySound:NO];
        } else { // no active alarm for this user, setup Normal Mode
            [SLAlarmManager handleStopAlarm];
        }
        
        [AppRoutinesManager startSafeletRoutinesForUser:[User currentUser]];
        
        // load the main menu view controller
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:kMainStoryboardName
                                                             bundle:nil];
        
        UIViewController *contentVC = [storyboard instantiateViewControllerWithIdentifier:[SlideMenuMainViewController storyboardID]];
        UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController:contentVC];
        
        self.window.rootViewController = navC;
        
        // then handle the notification, which means that the app current VC can change
        NSDictionary *pushNotificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (pushNotificationPayload) {
            [[SLPushNotificationManager sharedManager] handlePushNotificationDictionaryPayload:pushNotificationPayload
                                                                                     showAlert:NO]; // no alert
        }
    }];
}

@end
