//
//  NavigationBarAppearanceManager.m
//  Safelet
//
//  Created by Alex Motoc on 23/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"
#import "SLNavBarAppearanceManager.h"

@implementation SLNavBarAppearanceManager

+ (void)setupDefaultNavigationBar {
    // sets the UINavigationBar color
    [UINavigationBar appearance].barTintColor = nil;
    [UINavigationBar appearance].translucent = YES;
    
    // sets the UINavigationItem color (for buttons)
    [UINavigationBar appearance].tintColor = nil;
    
    // sets the color on navigationItem.title
    [UINavigationBar appearance].titleTextAttributes =@{
                                                        NSForegroundColorAttributeName:[UIColor blackColor],
                                                        };
}

+ (void)setupRedNavigationBar {
    // custom green color
    UIColor *color = [UIColor appThemeColor];
    
    // sets the UINavigationBar color
    [UINavigationBar appearance].barTintColor = color;
    [UINavigationBar appearance].translucent = NO;
    
    // sets the UINavigationItem color (for buttons)
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    
    // sets the color on navigationItem.title
    [UINavigationBar appearance].titleTextAttributes =@{
                                                        NSForegroundColorAttributeName:[UIColor whiteColor],
                                                        };
}

@end
