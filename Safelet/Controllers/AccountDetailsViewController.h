//
//  CreateAccountDetailInfoViewController.h
//  Safelet
//
//  Created by Mihai Eros on 9/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "User.h"
#import "BackgroundImageViewController.h"
#import <UIKit/UIKit.h>

@interface AccountDetailsViewController : BackgroundImageViewController

@property (strong, nonatomic) User *user;

@end
