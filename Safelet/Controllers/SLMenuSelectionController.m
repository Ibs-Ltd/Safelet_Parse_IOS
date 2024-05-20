//
//  SLMenuSelectionController.m
//  Safelet
//
//  Created by Alex Motoc on 05/12/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "SLMenuSelectionController.h"
#import "SlideMenuMainViewController.h"
#import "LeftMenuTableViewController.h"
#import "SLAlarmManager.h"
#import "User+Requests.h"
#import "User+Logout.h"
#import "Utils.h"
#import "SLErrorHandlingController.h"
#import "SafeletUnitManager.h"
#import "SLDevice.h"
#import "UIAlertController+Global.h"
#import <MessageUI/MessageUI.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface SLMenuSelectionController() <MFMailComposeViewControllerDelegate>

@end

@implementation SLMenuSelectionController

+ (instancetype)sharedController {
    static SLMenuSelectionController *controller;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [self new];
    });
    
    return controller;
}

- (void)handleAlarmSelectionFromMenu:(SlideMenuMainViewController *)menuViewController {
    if (menuViewController == nil) {
        menuViewController = [SlideMenuMainViewController currentMenu];
    }
    
    SLAlarmManager *alarmManager = [SLAlarmManager sharedManager];
    
    if (alarmManager.alarm.isActive) {
        return;
    } else {
        [[User currentUser] dispatchAlarmWithCompletion:^(Alarm * _Nullable alarm,
                                                          NSError * _Nullable error) {
            if (error) {
                [SLErrorHandlingController handleError:error];
            } else if (!alarm) {
                NSString *errMsg = NSLocalizedString(@"There was an error dispatching the alert. Please try again",
                                                     @"An error occurred while dispatching an alert");
                [UIAlertController showErrorAlertWithMessage:errMsg];
            } else {
                [SLAlarmManager handleDispatchAlarm:alarm shouldPlaySound:YES];
                [[SafeletUnitManager shared] performDispatchAlarmConfirmation:^(NSError *error) {
                    if (error) {
                        [SLErrorHandlingController handleError:error];
                    }
                }];
                
                // in LeftMenuTableViewController prepareForSegue: we do customisation for AlarmViewController
                [menuViewController.leftMenu performSegueWithIdentifier:menuViewController.alarmSegueIdentifier
                                                                 sender:nil];
            }
        }];
    }
}

- (void)handleEventsSelectionFromMenu:(SlideMenuMainViewController *)menuViewController {
    LeftMenuTableViewController *leftMenu = (LeftMenuTableViewController *)menuViewController.leftMenu;
    [leftMenu performSegueWithIdentifier:menuViewController.eventsSegueIdentifier
                                  sender:nil];
}

- (void)handleConnectSafeletSelectionFromMenu:(SlideMenuMainViewController *)menuViewController {
    BluetoothConnectionStatus status = [SafeletUnitManager shared].currentBluetoothStatus;
    if (status == BluetoothConnectionStatusPoweredOff ||
        status == BluetoothConnectionStatusUnauthorized ||
        status == BluetoothConnectionStatusUnsupported) {
        return; // bluetooth not connected => you can't connect or disconnect
    }
    
    if ([SafeletUnitManager shared].safeletPeripheral && [SafeletUnitManager shared].safeletPeripheral.isConnected == NO) {
        [self handleDisconnectSafeletActionNoConnection:menuViewController];
        return;
    } else if ([SafeletUnitManager shared].safeletPeripheral == nil) {
        UIViewController *controller = [menuViewController.storyboard instantiateViewControllerWithIdentifier:@"connectSafeletNavigationController"];
        [[menuViewController.currentActiveNVC.viewControllers lastObject] presentViewController:controller animated:YES completion:^{
            [menuViewController closeLeftMenuAnimated:NO];
        }];
        return;
    }
    
    [self handleDisconnectSafeletAction:menuViewController];
}

- (void)handleLogOutSelectionFromMenu:(SlideMenuMainViewController *)menuViewController {
    NSString *title = NSLocalizedString(@"Warning", nil);
    NSString *msg = NSLocalizedString(@"Are you sure you want to log out of the application?", nil);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
        [User logoutAndShowLoginScreen]; // logout and show login screen
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [menuViewController presentViewController:alert animated:YES completion:nil];
}

- (void)handleFeedbackSelectionFromMenu:(SlideMenuMainViewController *)menuViewController {
    if ([MFMailComposeViewController canSendMail] == NO) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Your device isn't configured to send emails", nil)];
        return;
    }
    
    // bracelet info
    NSString *firmwareVersion = @"No Safelet connected";
    SafeletDeviceInfoService *deviceInfoService = [SafeletUnitManager shared].safeletPeripheral.deviceInfo;
    if (deviceInfoService != nil) {
        firmwareVersion = [NSString stringWithFormat:@"Safelet bracelet firmware %@", deviceInfoService.firmwareRev];
    }
    
    // phone info
    SLDevice *device = [SLDevice currentDevice];
    NSString *deviceInfo = [NSString stringWithFormat:@"%@ - %@", device.model, device.osVersion];
    
    // app version info
    NSString *releaseVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *appVersion = [NSString stringWithFormat:@"%@ (build %@)", releaseVersion, buildVersion];
    
    NSString *extraInfo = @"";
    extraInfo = [extraInfo stringByAppendingFormat:@"User info: %@\n", [User currentUser].username];
    extraInfo = [extraInfo stringByAppendingFormat:@"App version: %@\n", appVersion];
    extraInfo = [extraInfo stringByAppendingFormat:@"Phone info: %@\n", deviceInfo];
    extraInfo = [extraInfo stringByAppendingFormat:@"Safelet bracelet info: %@\n", firmwareVersion];
    
    NSString *mailBody = [NSString stringWithFormat:@"\n\n\n%@", extraInfo];

    MFMailComposeViewController *mailVC = [MFMailComposeViewController new];
    mailVC.mailComposeDelegate = self;
    [mailVC setSubject:@"Safelet iOS support"];
    [mailVC setToRecipients:@[@"safeletcomsupport@safelet.freshdesk.com"]];
    [mailVC setMessageBody:mailBody isHTML:NO];
    mailVC.navigationBar.tintColor = [UIColor whiteColor];
    
    __weak typeof (menuViewController) weakMenu = menuViewController;
    [menuViewController presentViewController:mailVC animated:YES completion:^{
        [weakMenu closeLeftMenuAnimated:NO];
    }];
}

#pragma mark - MFMailComposeDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

// when the app and bracelet are connected and the user taps Disconnect Safelet
- (void)handleDisconnectSafeletAction:(SlideMenuMainViewController *)menuViewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Disconnect Safelet", nil)
                                                                   message:NSLocalizedString(@"Are you sure you want to disconnect your Safelet?", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                                                [[SafeletUnitManager shared] removeRelationForCurrentSafeletWithCompletion:^(NSError *error) {
                                                    [hud hideAnimated:YES];
                                                    
                                                    if (error) {
                                                        [SLErrorHandlingController handleError:error];
                                                    } else {
                                                        // reload data because it changes the side menu button title
                                                        //                                               [menuViewController.leftMenu.tableView reloadData];
                                                        [UIAlertController showSuccessAlertWithMessage:NSLocalizedString(@"The Safelet bracelet and the Safelet app are not longer connected. They are ready to reconnect", nil)];
                                                    }
                                                }];
                                            }]];
    
    [alert show:YES];
}

// when the app is no connected to the bracelet, but user still taps Disconnect Safelet
- (void)handleDisconnectSafeletActionNoConnection:(SlideMenuMainViewController *)menuViewController {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Disconnect Safelet", nil)
                                                                   message:NSLocalizedString(@"Your Safelet is not currently connected. Are you sure you want to remove the relation with your Safelet from your phone only?", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [[SafeletUnitManager shared] removeRelationForDisconnectedCurrentDevice];
                                                [menuViewController.leftMenu.tableView reloadData]; // reload data because it changes the side menu button title
                                                
                                                [UIAlertController showSuccessAlertWithMessage:NSLocalizedString(@"The Safelet app is not longer connected to a Safelet bracelet. Before you can reconnect you still need to reset the Safelet bracelet", nil)];
                                            }]];
    
    [alert show:YES];
}

@end
