//
//  NavigationBarAppearanceManager.h
//  Safelet
//
//  Created by Alex Motoc on 23/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLNavBarAppearanceManager : NSObject

/**
 *	Reset the navigation bar to default iOS appearance
 */
+ (void)setupDefaultNavigationBar;

/**
 *	Set the nav bar to red color. Used when the app is in Alarm Mode, caused by the current user dispatching an alarm
 */
+ (void)setupRedNavigationBar;

@end
