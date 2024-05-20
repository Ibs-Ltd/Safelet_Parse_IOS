//
//  CountryCodeNavigationController.m
//  Safelet
//
//  Created by Mihai Eros on 10/19/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "WhiteStatusBarNavigationController.h"
#import "AccountDetailsViewController.h"

@interface WhiteStatusBarNavigationController ()

@end

@class AccountDetailsViewController;
@implementation WhiteStatusBarNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
#warning Hack implementation to set default status bar color for CountryCodeVC
    // if a view controller is presented from the AccountDetailsViewController,
    // then the status bar must have default style
    
    if ([self.presentingViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *presentingNavC = (UINavigationController *)self.presentingViewController;
        
        if ([presentingNavC.topViewController isKindOfClass:[AccountDetailsViewController class]]) {
            return UIStatusBarStyleDefault;
        }
    }
    
    // otherwise it must be light content
    return UIStatusBarStyleLightContent;
}

@end
