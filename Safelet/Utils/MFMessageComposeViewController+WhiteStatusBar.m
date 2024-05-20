//
//  MFMessageComposeViewController+WhiteStatusBar.m
//  Safelet
//
//  Created by Alex Motoc on 22/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "MFMessageComposeViewController+WhiteStatusBar.h"

@implementation MFMessageComposeViewController (WhiteStatusBar)

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return nil;
}

@end
