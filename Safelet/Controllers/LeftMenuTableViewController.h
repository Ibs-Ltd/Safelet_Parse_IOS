//
//  LefMenuViewController.h
//  Safelet
//
//  Created by Mihai Eros on 9/28/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "GenericConstants.h"
#import "AMSlideMenuLeftTableViewController.h"

@interface LeftMenuTableViewController : AMSlideMenuLeftTableViewController

@property (nonatomic) SLContentType currentContentType;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@property (weak, nonatomic) IBOutlet UIImageView *imgUser;
- (void)placeCheckMarkForCommunityMember;

@end
