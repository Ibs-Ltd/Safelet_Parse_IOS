//
//  AppVersionManager.m
//  Safelet
//
//  Created by Alex Motoc on 25/07/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "AppVersionManager.h"
#import "AppVersionRequest.h"
#import "SLErrorHandlingController.h"
#import <StoreKit/StoreKit.h>

static NSString * const kLastUpdateCheckKey = @"lastUpdateCheck";
static NSInteger const kAppITunesItemIdentifier = 1079472866;

@interface AppVersionManager () <SKStoreProductViewControllerDelegate>
@property (strong, nonatomic) UIWindow *alertWindow;
@end

@implementation AppVersionManager

+ (instancetype)sharedManager {
    static AppVersionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    
    return manager;
}

- (void)checkForLatestAppVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastCheck = [defaults objectForKey:kLastUpdateCheckKey];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay
                                               fromDate:lastCheck
                                                 toDate:[NSDate date]
                                                options:0];
    
    if (lastCheck == nil || components.day >= 7) {
        AppVersionRequest *request = [AppVersionRequest request];
        [request setRequestCompletionBlock:^(NSString * _Nullable liveVersion, NSError * _Nullable error) {
            if (error) {
                [SLErrorHandlingController handleError:error];
                return;
            }
            NSLog(@"TEST%@",error);
            [defaults setObject:[NSDate date] forKey:kLastUpdateCheckKey];
            [defaults synchronize];
            
            NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSLog(@"TEST%@",liveVersion);
            if ([currentVersion compare:liveVersion] == NSOrderedAscending) { // i.e. currentVersion < liveVersion
                [self showUpdateAvailableAlert:liveVersion];
            }
        }];
        
        [request runRequest];
    }
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [viewController dismissViewControllerAnimated:YES completion:^{
        self.alertWindow.hidden = YES;
        self.alertWindow = nil;
    }];
}

#pragma mark - Utils

- (void)showUpdateAvailableAlert:(NSString *)updateVersion {
    NSString *message = NSLocalizedString(@"A new app version is available", nil);
    message = [message stringByAppendingString:[NSString stringWithFormat:@": %@", updateVersion]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update available", nil)
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                self.alertWindow.hidden = YES;
                                                self.alertWindow = nil;
                                            }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                self.alertWindow.hidden = YES;
                                                self.alertWindow = nil;
                                                
                                                [self showAppStorePage];
                                            }]];
    
    [self showViewController:alert];
}

- (void)showAppStorePage {
    SKStoreProductViewController *storeViewController = [SKStoreProductViewController new];
    storeViewController.delegate = self;
    
    NSNumber *identifier = [NSNumber numberWithInteger:kAppITunesItemIdentifier];
    NSDictionary *parameters = @{ SKStoreProductParameterITunesItemIdentifier:identifier };
    
    [storeViewController loadProductWithParameters:parameters
                                   completionBlock:^(BOOL result, NSError *error) {
                                       if (error) {
                                           [SLErrorHandlingController handleError:error];
                                           return;
                                       }
                                       
                                       [self showViewController:storeViewController];
                                   }];
}

- (void)showViewController:(UIViewController *)controller {
    self.alertWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.alertWindow.rootViewController = [[UIViewController alloc] init];
    
    // we inherit the main window's tintColor
    self.alertWindow.tintColor = [UIApplication sharedApplication].delegate.window.tintColor;
    // window level is above the top window (this makes the alert, if it's a sheet, show over the keyboard)
    UIWindow *topWindow = [UIApplication sharedApplication].windows.lastObject;
    self.alertWindow.windowLevel = topWindow.windowLevel + 1;
    
    [self.alertWindow makeKeyAndVisible];
    [self.alertWindow.rootViewController presentViewController:controller animated:YES completion:nil];
}

@end
