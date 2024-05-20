//
//  EventsCheckInTableViewCell.m
//  Safelet
//
//  Created by Mihai Eros on 10/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EventsCheckInTableViewCell.h"
#import "User.h"
#import "CheckIn.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FormatterKit/TTTTimeIntervalFormatter.h>

@implementation EventsCheckInTableViewCell

#pragma mark - Populate cell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.locationLabel.textColor = [UIColor appThemeColor];
}

- (void)populateWithCheckIn:(CheckIn *)checkIn {
    NSString *checkInDescripion = [checkIn.user.name stringByAppendingString:NSLocalizedString(@" checked in ",
                                                                                       @"check in")];
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    NSString *timeStamp = [timeIntervalFormatter stringForTimeInterval:checkIn.updatedAt.timeIntervalSinceNow];
    
    self.checkInDetailsLabel.text = [checkInDescripion stringByAppendingString:timeStamp];
    self.messageLabel.text = checkIn.message;
    self.locationLabel.text = checkIn.locationName;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:checkIn.user.userImage.url]
                          placeholderImage:[UIImage imageNamed:@"generic_icon"]];
}

+ (NSString *)identifier {
    return @"checkInCell";
}

@end
