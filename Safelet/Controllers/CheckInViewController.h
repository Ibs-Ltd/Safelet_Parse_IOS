//
//  CheckInViewController.h
//  Safelet
//
//  Created by Mihai Eros on 10/1/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BannerEnabledViewController.h"
#import <UIKit/UIKit.h>

@class User;
@class CheckIn;

@interface CheckInViewController : BannerEnabledViewController

/**
 *  Method used to instantiated the ViewController with user's
 *  check-in object and its properties.
 *
 *  @param checkIn check-in model object
 *
 *  @return CheckInViewController with myConnectionsCheckIn set
 */

+ (instancetype)createForUserCheckIn:(CheckIn *)checkIn;

@end
