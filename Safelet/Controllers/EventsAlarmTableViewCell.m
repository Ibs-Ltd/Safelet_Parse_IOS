//
//  EventsAlarmTableViewCell.m
//  Safelet
//
//  Created by Mihai Eros on 10/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EventsAlarmTableViewCell.h"
#import "Alarm.h"
#import "User+Requests.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface EventsAlarmTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *alarmLabel;
@end

@implementation EventsAlarmTableViewCell

#pragma mark - Populate cell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.contentView.backgroundColor = [UIColor bigTableCellColor];
}

- (void)populateWithAlarm:(Alarm *)alarm
                 delegate:(id<EventsAlarmCellDelegate> _Nullable)delegate {
    self.alarm = alarm;
    self.delegate = delegate;
    
    NSString *partialDescription = NSLocalizedString(@"NEEDS YOUR HELP!",
                                                   @"help is needed EventsAlarmTableViewCell");
    NSString *alarmDescription = [NSString stringWithFormat:@"%@, \n%@", alarm.user.name, partialDescription];
    self.alarmLabel.text = alarmDescription;
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:alarm.user.userImage.url]
                          placeholderImage:[UIImage imageNamed:@"generic_icon"]];
}

+ (NSString *)identifier {
    return @"alarmCell";
}

#pragma mark - IBActions

- (IBAction)didTapSeeDetailsButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(alarmCellDidSelectSeeDetails:)]) {
        [self.delegate alarmCellDidSelectSeeDetails:self];
    }
}

- (IBAction)didTapIgnoreButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(alarmCellDidSelectIgnoreAlarm:)]) {
        [self.delegate alarmCellDidSelectIgnoreAlarm:self];
    }
}

@end
