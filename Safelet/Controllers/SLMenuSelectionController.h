//
//  SLMenuSelectionController.h
//  Safelet
//
//  Created by Alex Motoc on 05/12/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *	Controller used when additional actions are required when selecting an app section
 */

@class SlideMenuMainViewController;
@interface SLMenuSelectionController : NSObject

+ (instancetype)sharedController;
- (void)handleAlarmSelectionFromMenu:(SlideMenuMainViewController *)menuViewController;
- (void)handleEventsSelectionFromMenu:(SlideMenuMainViewController *)menuViewController;
- (void)handleConnectSafeletSelectionFromMenu:(SlideMenuMainViewController *)menuViewController;
- (void)handleLogOutSelectionFromMenu:(SlideMenuMainViewController *)menuViewController;
- (void)handleFeedbackSelectionFromMenu:(SlideMenuMainViewController *)menuViewController;

@end
