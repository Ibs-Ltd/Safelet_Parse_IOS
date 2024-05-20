//
//  BannerEnabledViewController.h
//  Safelet
//
//  Created by Alex Motoc on 09/02/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *	View Controller used to add a padding to the presented content, such that it will not go under the Alarm banner
 *  View controllers that are subclass of this view controller, will have their content size adjusted so it
 *  will not go under the banner
 */
@interface BannerEnabledViewController : UIViewController
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@end
