//
//  MainViewController.h
//  Safelet
//
//  Created by Mihai Eros on 9/28/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "AMSlideMenuMainViewController.h"

@interface SlideMenuMainViewController : AMSlideMenuMainViewController

@property (strong, nonatomic, getter=gettingStartedSegueIdentifier) NSString *gettingStartedSegue;
@property (strong, nonatomic, getter=homeSegueIdentifier) NSString *homeSegue;
@property (strong, nonatomic, getter=myConnectionsSegueIdentifier) NSString *myConnectionsSegue;
@property (strong, nonatomic, getter=eventsSegueIdentifier) NSString *eventsSegue;
@property (strong, nonatomic, getter=myProfileSegueIdentifier) NSString *myProfileSegue;
@property (strong, nonatomic, getter=guardianNetworkSegueIdentifier) NSString *guardianNetworkSegue;
@property (strong, nonatomic, getter=alarmSegueIdentifier) NSString *alarmSegue;
@property (strong, nonatomic, getter=checkInSegueIdentifier) NSString *checkInSegue;
@property (strong, nonatomic, getter=optionsSegueIdentifier) NSString *optionsSegue;

+ (NSString *)storyboardID;
+ (instancetype)currentMenu;

@end
