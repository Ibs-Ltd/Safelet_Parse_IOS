//
//  UserCell.h
//  Safelet
//
//  Created by Mihai Eros on 10/27/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const kcellConnectionIdentifier = @"connectionCell"; // ConnectionCell identifier

@class User;
@interface ConnectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

- (void)populateWithUser:(User *)user;

@end
