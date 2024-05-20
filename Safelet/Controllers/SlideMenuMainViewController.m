//
//  MainViewController.m
//  Safelet
//
//  Created by Mihai Eros on 9/28/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "SlideMenuMainViewController.h"
#import "User+Requests.h"
#import "User+Logout.h"
#import "Utils.h"
#import "SLAlarmManager.h"
#import "SLLocationManager.h"
#import "SLNavBarAppearanceManager.h"
#import "SLErrorHandlingController.h"
#import "SLDataManager.h"
#import "SLMenuSelectionController.h"
#import "SLPermissionManager.h"
#import "GenericConstants.h"
#import <MBProgressHUD/MBProgressHUD.h>

// possible content classes
#import "MyConnectionsViewController.h"
#import "EventsTableViewController.h"
#import "MyProfileTableViewController.h"
#import "AlarmViewController.h"
#import "GuardianNetworkViewController.h"
#import "ConnectSafeletIntroViewController.h"
#import "CheckInViewController.h"
#import "LoginViewController.h"
#import "LeftMenuTableViewController.h"
#import "OptionsTableViewController.h"

// segue identifiers
static NSString * const kSlideMenuSegueIdentifierGettingStarted = @"getting_started";
static NSString * const kSlideMenuSegueIdentifierHome = @"home";
static NSString * const kSlideMenuSegueIdentifierMyConnections = @"myConnections";
static NSString * const kSlideMenuSegueIdentifierEvents = @"events";
static NSString * const kSlideMenuSegueIdentifierMyProfile = @"myProfile";
static NSString * const kSlideMenuSegueIdentifierGuardianNetwork = @"guardianNetwork";
static NSString * const kSlideMenuSegueIdentifierAlarm = @"alarm";
static NSString * const kSlideMenuSegueIdentifierCheckIn = @"checkIn";
static NSString * const kSlideMenuSegueIdentifierOptions = @"options";

@interface SlideMenuMainViewController () <AMSlideMenuDelegate>
@property (nonatomic) BOOL didSetupFirstScreen;
@end

@implementation SlideMenuMainViewController

+ (NSString *)storyboardID {
    return @"SlideMenuViewControllerID";
}

+ (instancetype)currentMenu {
    return [[SlideMenuMainViewController allInstances].lastObject nonretainedObjectValue];
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.slideMenuDelegate = self;
    [SLNavBarAppearanceManager setupRedNavigationBar];
    [SLPermissionManager requestMicrophonePermission];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - AMSlideMenuMainViewController overridden config methods

- (void)configureSlideLayer:(CALayer *)layer {
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 1;
    layer.shadowOffset = CGSizeMake(0, 0);
    layer.shadowRadius = 5;
    layer.masksToBounds = NO;
    layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
}

- (UIViewAnimationOptions)openAnimationCurve {
    return UIViewAnimationOptionCurveEaseOut;
}

- (UIViewAnimationOptions)closeAnimationCurve {
    return UIViewAnimationOptionCurveEaseOut;
}

// Enabling Deepnes on left menu
- (BOOL)deepnessForLeftMenu {
    return YES;
}

// Enabling Deepnes on left menu
- (BOOL)deepnessForRightMenu {
    return YES;
}

// Enabling darkness while left menu is opening
- (CGFloat)maxDarknessWhileLeftMenu {
    return 0.5;
}

// Enabling darkness while right menu is opening
- (CGFloat)maxDarknessWhileRightMenu {
    return 0.5;
}

- (void)configureLeftMenuButton:(UIButton *)button {
    CGRect frame = button.frame;
    frame = CGRectMake(0, 0, 44, 44);
    button.frame = frame;
    button.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    button.backgroundColor = [UIColor clearColor];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setImage:[UIImage imageNamed:@"simple_menu_button"] forState:UIControlStateNormal];
}

- (NSString *)segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath {
#warning Bad implementation of content type retrieval; shouldn't be coupled with the order of the table cells
    SLContentType nextContentType = (SLContentType)indexPath.row;
    if(indexPath.section == 2){
        nextContentType = (SLContentType)8;
    }
    SLContentType currentContentType = ((LeftMenuTableViewController *)self.leftMenu).currentContentType;
    
    if(self.currentActiveNVC.viewControllers.count == 0 && currentContentType == SLContentTypeHome && nextContentType != SLContentTypeHome){
        nextContentType = SLContentTypeHome;
    }
    
    NSString *identifier = @"";
    
    if (currentContentType == nextContentType && self.currentActiveNVC.viewControllers.count > 0) { // user selected content that is already loaded
        if (currentContentType == SLContentTypeAlarm && [SLAlarmManager sharedManager].alarm == nil) {
            [[SLMenuSelectionController sharedController] handleAlarmSelectionFromMenu:self];
        } else {
            [self closeLeftMenuAnimated:YES];
        }
        return identifier; // return empty string as segue identifier, so no segue is triggered
    } else {
        // present the alarm section if the app was just opened and there is an active alarm for this user
        if (!self.didSetupFirstScreen && [SLAlarmManager sharedManager].alarm.isActive) {
            self.didSetupFirstScreen = YES; // set yes here because we are returning and don't reach last line
            return kSlideMenuSegueIdentifierAlarm;
        }
        
        switch (nextContentType) {
            case SLContentTypeGettingStarted:
                identifier = kSlideMenuSegueIdentifierGettingStarted;
                break;
            case SLContentTypeHome:
                identifier = kSlideMenuSegueIdentifierHome;
                break;
            case SLContentTypeMyConnections:
                identifier = kSlideMenuSegueIdentifierMyConnections;
                break;
            case SLContentTypeEvents:
                [[SLMenuSelectionController sharedController] handleEventsSelectionFromMenu:self];
                break;
            case SLContentTypeMyProfile: {
                identifier = kSlideMenuSegueIdentifierMyProfile;
                break;
            }
            case SLContentTypeGuardianNetwork:
                identifier = kSlideMenuSegueIdentifierGuardianNetwork;
                break;
            case SLContentTypeCheckIn:
                identifier = kSlideMenuSegueIdentifierCheckIn;
                break;
            case SLContentTypeConnectSafelet: {
                [[SLMenuSelectionController sharedController] handleConnectSafeletSelectionFromMenu:self];
                break;
            }
            case SLContentTypeAlarm:
                if ([SLAlarmManager sharedManager].alarm == nil) {
                    [[SLMenuSelectionController sharedController] handleAlarmSelectionFromMenu:self]; // hanlde alarm
                    return @""; // no need to segue until request finishes
                }
                return kSlideMenuSegueIdentifierAlarm; // will cause to segue
            case SLContentTypeOptions:
                identifier = kSlideMenuSegueIdentifierOptions;
                break;
            case SLContentTypeFeedback:
                [[SLMenuSelectionController sharedController] handleFeedbackSelectionFromMenu:self];
                break;
            case SLContentTypeLogOut: // user selected log out
                // segue identifier remains the empty string, so no segue is triggered
                [[SLMenuSelectionController sharedController] handleLogOutSelectionFromMenu:self];
                break;
            default:
                break;
        }
    }
    
    self.didSetupFirstScreen = YES;
    
    return identifier;
}

#pragma mark - AMSlideMenu delegate

- (void)leftMenuWillOpen {
    LeftMenuTableViewController *vc = (LeftMenuTableViewController *)self.leftMenu;
    [vc placeCheckMarkForCommunityMember];
}

#pragma mark - Getters
- (NSString *)myConnectionsSegueIdentifier {
    return kSlideMenuSegueIdentifierMyConnections;
}

- (NSString *)eventsSegueIdentifier {
    return kSlideMenuSegueIdentifierEvents;
}

- (NSString *)myProfileSegueIdentifier {
    return kSlideMenuSegueIdentifierMyProfile;
}

- (NSString *)guardianNetworkSegueIdentifier {
    return kSlideMenuSegueIdentifierGuardianNetwork;
}

- (NSString *)alarmSegueIdentifier {
    return kSlideMenuSegueIdentifierAlarm;
}

- (NSString *)checkInSegueIdentifier {
    return kSlideMenuSegueIdentifierCheckIn;
}

- (NSString *)optionsSegueIdentifier {
    return kSlideMenuSegueIdentifierOptions;
}
- (NSString *)homeSegueIdentifier {
    return kSlideMenuSegueIdentifierHome;
}
- (NSString *)gettingStartedSegueIdentifier {
    return kSlideMenuSegueIdentifierGettingStarted;
}
@end
