//
//  UserCell.m
//  Safelet
//
//  Created by Mihai Eros on 10/27/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "ConnectionCell.h"
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ConnectionCell

/**
 *  Method used in order to populate a cell with user data.
 *
 *  @param user an object of type User
 */
- (void)populateWithUser:(User *)user {
    self.imageView.layer.cornerRadius = 2;
    self.imageView.clipsToBounds = YES;
    
    // if user is not nil, populate IBOutlets with user info
    if (user) {
        self.userNameLabel.text = user.name;
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:user.userImage.url]
                          placeholderImage:[UIImage imageNamed:@"generic_icon"]];
    } else { // else default
        self.userNameLabel.text = @"";
        [self.imageView setImage:[UIImage imageNamed:@"add_icon"]];
    }
}

@end
