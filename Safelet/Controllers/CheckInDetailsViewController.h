//
//  CheckInDetailsViewController.h
//  Safelet
//
//  Created by Mihai Eros on 10/29/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BannerEnabledViewController.h"
#import <UIKit/UIKit.h>

@class CheckIn;

@interface CheckInDetailsViewController : BannerEnabledViewController

@property (strong, nonatomic) CheckIn *checkIn;
+ (instancetype)createDetailsCheckIn:(CheckIn *)checkIn;

@end
