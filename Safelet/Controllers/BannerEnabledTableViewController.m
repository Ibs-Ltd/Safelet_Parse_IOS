//
//  BannerEnabledTableViewController.m
//  Safelet
//
//  Created by Alex Motoc on 09/02/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BannerEnabledTableViewController.h"
#import "AlarmBannerView.h"
#import "SLAlarmManager.h"

@interface BannerEnabledTableViewController ()

@end

@implementation BannerEnabledTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([SLAlarmManager sharedManager].alarm) {
        UIEdgeInsets inset = UIEdgeInsetsMake([AlarmBannerView bannerHeight], 0, 0, 0);
        self.tableView.contentInset = inset;
    }
}


@end
