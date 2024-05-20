//
//  EventsHistoricAlarmTableViewCell.m
//  Safelet
//
//  Created by Alex Motoc on 14/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "EventsHistoricAlarmTableViewCell.h"
#import "Alarm.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FormatterKit/TTTTimeIntervalFormatter.h>

@interface EventsHistoricAlarmTableViewCell ()
@property (strong, nonatomic) Alarm *alarm;
@property (weak, nonatomic) id  <EventsHistoricAlarmCellDelegate> _Nullable delegate;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playRecordingButton;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *stopReasonLabel;
@end

@implementation EventsHistoricAlarmTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.playRecordingButton setBackgroundImage:[UIImage imageNamed:@"green_button_560x90"] forState:UIControlStateNormal];
    [self.playRecordingButton setBackgroundImage:[UIImage new] forState:UIControlStateDisabled];
    
    [self.playRecordingButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.playRecordingButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
}

- (void)populateWithAlarm:(Alarm *)alarm
                 delegate:(id<EventsHistoricAlarmCellDelegate> _Nullable)delegate {
    self.delegate = delegate;
    self.alarm = alarm;
    
    NSDateFormatter* dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateStyle:NSDateFormatterLongStyle];
    [dtFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.dateLabel.text = [dtFormatter stringFromDate:alarm.createdAt];
    
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", alarm.user.name,
                            NSLocalizedString(@"dispatched an alarm", nil)];
    
    if (alarm.recordingChunksCount > 0) {
        self.playRecordingButton.enabled = YES;
    } else {
        self.playRecordingButton.enabled = NO;
    }
    
    NSString *reason = NSLocalizedString(@"Disable reason:", nil);
    if (alarm.stopAlarmReason) {
        switch ([alarm.stopAlarmReason selectedStopReason]) {
            case StopReasonTestAlarm:
                reason = [reason stringByAppendingString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"this was a test alarm", nil)]];
                break;
            case StopReasonAccidentalAlarm:
                reason = [reason stringByAppendingString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"this was an accidental alarm", nil)]];
                break;
            case StopReasonHelpNoLongerNeeded:
                reason = [reason stringByAppendingString:[NSString stringWithFormat:@" %@", NSLocalizedString(@"help is no longer needed", nil)]];
                break;
            case StopReasonOther:
                reason = [reason stringByAppendingString:[NSString stringWithFormat:@" %@", alarm.stopAlarmReason.otherReasonDescription ?: @"other"]];
                break;
            default:
                break;
        }
    } else {
        reason = NSLocalizedString(@"No reason for disabling alarm", nil);
    }
    
    self.stopReasonLabel.text = reason;
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:alarm.user.userImage.url]
                          placeholderImage:[UIImage imageNamed:@"generic_icon"]];
}

+ (NSString *)identifier {
    return @"historicAlarmCell";
}

- (IBAction)didTapPlayRecording:(id)sender {
    if ([self.delegate respondsToSelector:@selector(historicAlarmCellDidSelectPlayRecordingForAlarm:)]) {
        [self.delegate historicAlarmCellDidSelectPlayRecordingForAlarm:self.alarm];
    }
}

@end
