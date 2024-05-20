//
//  BannerEnabledViewController.m
//  Safelet
//
//  Created by Alex Motoc on 09/02/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BannerEnabledViewController.h"
#import "AlarmBannerView.h"
#import "SLAlarmManager.h"

@interface BannerEnabledViewController ()

@end

@implementation BannerEnabledViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.topConstraint && [SLAlarmManager sharedManager].alarm) {
        self.topConstraint.constant += [AlarmBannerView bannerHeight];
    }
}

@end
