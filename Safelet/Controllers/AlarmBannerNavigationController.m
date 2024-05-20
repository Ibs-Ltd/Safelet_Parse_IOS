//
//  AlarmBannerNavigationController.m
//  Safelet
//
//  Created by Alex Motoc on 09/02/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "AlarmBannerNavigationController.h"
#import "SlideMenuMainViewController.h"
#import "LeftMenuTableViewController.h"
#import "SLAlarmManager.h"
#import "SLAlarmRecordingManager.h"
#import "AlarmBannerView.h"
#import "AlarmViewController.h"
#import "Safelet-Swift.h"

@interface AlarmBannerNavigationController () <UIGestureRecognizerDelegate, SLAlarmRecordingDelegate>
@property (weak, nonatomic) AlarmBannerView *bannerView; // the banner that we will show
@end

@implementation AlarmBannerNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SLAlarmRecordingManager sharedManager].delegate = self;
    
    // if there is an active alarm dispatched by the current user, display the banner
    if ([SLAlarmManager sharedManager].alarm) {
        self.bannerView = [AlarmBannerView createFromNib];
        
        if ([SLAlarmRecordingManager sharedManager].isRecording) {
            [self.bannerView setRecordingLabelHidden:NO];
        }
        
        [self.navigationBar addSubview:self.bannerView]; // add the banner to the nav bar
        
        // the banner has subviews that are arranged using constraints, therefore we must add constraints programatically
        // for the banner, in order to ensure it is displayed properly
        [self.bannerView addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:self.bannerView
                                                                    attribute:NSLayoutAttributeHeight
                                                                   multiplier:0
                                                                     constant:[AlarmBannerView bannerHeight]]];
        
        [self.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                                       attribute:NSLayoutAttributeLeading
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.navigationBar
                                                                       attribute:NSLayoutAttributeLeading
                                                                      multiplier:1
                                                                        constant:0]];
        
        [self.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.navigationBar
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1
                                                                        constant:0]];
        
        [self.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:self.bannerView
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.navigationBar
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1
                                                                        constant:self.navigationBar.frame.size.height]];
        
        // add a gesture recognizer so we know when the banner is touched
        UITapGestureRecognizer *reco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapContent:)];
        reco.cancelsTouchesInView = NO;
        reco.delegate = self;
        [self.view addGestureRecognizer:reco];
    }
}

- (void)didTapContent:(UIGestureRecognizer *)gestureRecognizer {
    // when the content was touched, check if there is an active alarm first
    // if there is an alarm, we know we also have a banner
    if ([SLAlarmManager sharedManager].alarm) {
        // compute the location of the touch, with respect to the nav bar
        CGPoint location = [gestureRecognizer locationInView:self.navigationBar];
        
        SlideMenuMainViewController *menu = [SlideMenuMainViewController currentMenu];
        
        // if the touch is in the navbar, in the banner area, jump to the Alarm section
        // also, the FIRST view controller in the current nav controller must not be AlarmVC,
        // because we don't want to show the same screen when the user taps on the banner
        // (explaned: when the firstVC is AlarmVC in the navC, that means the current user is
        // in his own alarm screen; if he is viewing some other alarm, the first VC would be EventsVC)
        if (CGRectContainsPoint(self.bannerView.frame, location) &&
            [[menu.currentActiveNVC.viewControllers firstObject] isKindOfClass:[AlarmPulleyContainerViewController class]] == NO) {
            [menu.leftMenu performSegueWithIdentifier:[menu alarmSegueIdentifier] sender:nil];
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([SLAlarmManager sharedManager].alarm) {
        CGPoint location = [gestureRecognizer locationInView:self.navigationBar];
        
        // recognize only this gesture if it's in the banner area
        // we don't care about any other gestures, because the banner tap is more important
        if (CGRectContainsPoint(self.bannerView.frame, location)) {
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - SLAlarmRecordingDelegate

- (void)recordingMangerDidStartRecording:(SLAlarmRecordingManager *)manager {
    [self.bannerView setRecordingLabelHidden:NO];
}

- (void)recordingMangerDidStopRecording:(SLAlarmRecordingManager *)manager {
    [self.bannerView setRecordingLabelHidden:YES];
}

@end
