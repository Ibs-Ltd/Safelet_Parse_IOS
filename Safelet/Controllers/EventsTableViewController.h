//
//  EventsTableViewController.h
//  Safelet
//
//  Created by Mihai Eros on 10/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "GenericConstants.h"
#import "BannerEnabledTableViewController.h"
#import <UIKit/UIKit.h>

@interface EventsTableViewController : BannerEnabledTableViewController
@property (nonatomic) EventContentType selectedEventContentType;
@end
