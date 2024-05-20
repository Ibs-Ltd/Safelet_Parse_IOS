//
//  LoadScreenViewController.h
//  Safelet
//
//  Created by Alex Motoc on 30/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *	View controller identical to the LaunchScreen one. Created this and custom storyboard (LoadScreen.storyboard)
 *  in order to present it when we need more time to load data after the splash screen, and to be able to
 *  have more control upon it (you can't use custom view controllers for the launch screen vc's)
 */
@interface LoadScreenViewController : UIViewController

@end
