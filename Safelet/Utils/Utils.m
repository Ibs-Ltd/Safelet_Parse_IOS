//
//  Utils.m
//  Safelet
//
//  Created by Alex Motoc on 05/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "Utils.h"
#import "Alarm.h"
#import "SLDataManager.h"
#import "UIAlertController+Global.h"
#import "AlarmViewController.h"
#import "AlarmActionsViewController.h"
#import "Safelet-Swift.h"

@import libPhoneNumber_iOS;

static NSInteger const kNotificationBatteryLevelOne = 20;
static NSInteger const kNotificationBatteryLevelTwo = 10;

@implementation Utils

+ (void)dispatchLocalNotificationForLowBatteryLevel:(NSInteger)batteryLevel {
    if (batteryLevel < 0) {
        return;
    }
    
    SLDataManager *manager = [SLDataManager sharedManager];
    NSInteger presentedNotificationsCount = manager.presentedLowBatteryNotificationsCount;

    if (batteryLevel > kNotificationBatteryLevelOne) {
        manager.presentedLowBatteryNotificationsCount = 0;
        return;
    } else if (batteryLevel <= kNotificationBatteryLevelOne && batteryLevel > kNotificationBatteryLevelTwo) {
        if (presentedNotificationsCount == 1) {
            return;
        } else if (presentedNotificationsCount == 2) {
             manager.presentedLowBatteryNotificationsCount = 1;
            return;
        }
        
        presentedNotificationsCount = 1;
    } else { // battery level <= kNotificationBatteryLevelTwo
        if (presentedNotificationsCount == 2) {
            return;
        }
        
        presentedNotificationsCount = 2;
    }
    
    manager.presentedLowBatteryNotificationsCount = presentedNotificationsCount;
    
    NSString *level = [NSString stringWithFormat:@" %ld\uFF05. ", (long)batteryLevel];
    NSString *batteryLevelString = [NSLocalizedString(@"Safelet battery level is", nil) stringByAppendingString:level];
    batteryLevelString = [batteryLevelString stringByAppendingString:NSLocalizedString(@"Please charge up your Safelet.", nil)];
    
    UILocalNotification *localNotif = [UILocalNotification new];
    localNotif.alertTitle = NSLocalizedString(@"Warning", nil);
    localNotif.alertBody = batteryLevelString;
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
}

+ (AlarmPulleyContainerViewController *)createChatAlarmControllerWithAlarm:(Alarm *)alarm shouldShowJoinAlarmButton:(BOOL)showJoinAlarm {
    AlarmViewController *alarmVC = [AlarmViewController createWithAlarm:alarm];
    AlarmActionsViewController *actionsVC = [AlarmActionsViewController createFromStoryboardWithAlarm:alarm];
    actionsVC.joinAlarmButtonEnabled = showJoinAlarm;
    
//    AlarmPulleyContainerViewController* pulleyVC =[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"AlarmPulleyContainerViewController"];
    
//    AlarmPulleyContainerViewController *pulleyVC = [[AlarmPulleyContainerViewController alloc] ];
//    pulleyVC.drawerContentContainerView = actionsVC.view;
//    pulleyVC.primaryContentContainerView = alarmVC.view;
    AlarmPulleyContainerViewController *pulleyVC = [[AlarmPulleyContainerViewController alloc] initWithContentViewController:alarmVC drawerViewController:actionsVC];
    
    
    pulleyVC.title = alarmVC.title;
    
    return pulleyVC;
}

@end

#pragma mark - Color Utils

@implementation UIColor (AppThemeColor)

+ (UIColor *)appThemeColor {
    return [UIColor colorWithRed:0.788 green:0.047 blue:0.063 alpha:1.000];
}

+ (UIColor *)alarmBannerColor {
    return [UIColor colorWithRed:0.600 green:0.098 blue:0.086 alpha:1.000];
}

+ (UIColor *)bigTableCellColor {
    return [UIColor colorWithRed:0.686 green:0.031 blue:0.047 alpha:1.000];
}

@end

#pragma mark - String utils

@implementation NSString (EmailValidation)

- (BOOL)isValidEmailFormat {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

@end

@implementation NSString (PhoneNumberUtils)

- (NSString *)normalizedPhoneNumberWithDefaultCountryCode:(NSString *)countryCode {
    NBPhoneNumberUtil *phoneNumberUtil = [NBPhoneNumberUtil new];
    NSString *region = [phoneNumberUtil getRegionCodeForCountryCode:@([countryCode integerValue])];
    
    
    NSError *err;
    NBPhoneNumber *number = [phoneNumberUtil parse:self defaultRegion:region error:&err];
    
    if (err) { // parsing failed
        // add country code and try again
        NSString *retryNumber = [countryCode stringByAppendingString:self];
        err = nil;
        number = [phoneNumberUtil parse:retryNumber defaultRegion:region error:&err];
        
        if (err) { // if second retry failed, return the phone number unchanged
            return self;
        }
    }
    
    err = nil;
    
    NSString *formatted = [phoneNumberUtil format:number numberFormat:NBEPhoneNumberFormatE164 error:&err];
    
    if (err) { // formatting failed
        return self; // return phone number unchanged
    }
    
    return formatted;
}

@end

@implementation NSString (GenericUtils)

+ (NSString *)stringWithFormat:(NSString *)format arguments:(NSArray *)args {
    if (args.count > 10) {
        @throw [NSException exceptionWithName:NSRangeException reason:@"Maximum of 10 arguments allowed" userInfo:@{@"collection": args}];
    }
    
    NSArray *a = [args arrayByAddingObjectsFromArray:@[@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X",@"X"]];
    return [NSString stringWithFormat:format, a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10]];
}

@end

#pragma mark - AlertView Utils

@implementation UIAlertController (ShortSyntax)

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:nil]];
    [alert show:YES];
}

+ (void)showErrorAlertWithMessage:(NSString *)message {
    [UIAlertController showAlertWithTitle:NSLocalizedString(@"Error", nil) message:message];
}

+ (void)showSuccessAlertWithMessage:(NSString *)message {
    [UIAlertController showAlertWithTitle:NSLocalizedString(@"Success", nil) message:message];
}

+ (void)showAlertWithMessage:(NSString *)message {
    [UIAlertController showAlertWithTitle:NSLocalizedString(@"Alert", nil) message:message];
}

+ (void)showPushNotificationAlertWithMessage:(NSString *)message
                                     handler:(void(^)(BOOL shouldShowDetails))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", nil)
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                handler(NO);
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"View", @"View a push notification in app")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                handler(YES);
                                            }]];
    
    [alert show:YES];
}
+ (void)showPushNotificationAlertWithMessageForFollowMe:(NSString *)message isShowDismiss:(BOOL)isShowDismiss handler:(void (^)(BOOL))handler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", nil)
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    if(isShowDismiss == true){
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil)
          style:UIAlertActionStyleCancel
        handler:^(UIAlertAction * _Nonnull action) {
            handler(NO);
        }]];
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                handler(YES);
                                            }]];
    
    [alert show:YES];
}

@end

@implementation UIImage(ImageUtils)

+ (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

@end
