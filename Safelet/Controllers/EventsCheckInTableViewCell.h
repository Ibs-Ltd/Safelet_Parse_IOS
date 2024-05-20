//
//  EventsCheckInTableViewCell.h
//  Safelet
//
//  Created by Mihai Eros on 10/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CheckIn;

@interface EventsCheckInTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkInDetailsLabel;

- (void)populateWithCheckIn:(CheckIn * _Nonnull)checkIn;
+ (NSString * _Nonnull)identifier;

@end

NS_ASSUME_NONNULL_END