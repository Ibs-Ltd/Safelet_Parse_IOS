//
//  BackgroundImageViewController.h
//  Safelet
//
//  Created by Alex Motoc on 09/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  View controller used as base; View controllers that inherit from this VC will present
 *  a "butterfly" image as background
 */
@interface BackgroundImageViewController : UIViewController

/**
 *  Sets the background image visible or not; default is visible
 *
 *  @param enabled boolean
 */
- (void)setbackgroundImageEnabled:(BOOL)enabled;

@end
