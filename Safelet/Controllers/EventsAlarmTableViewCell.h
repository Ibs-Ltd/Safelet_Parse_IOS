//
//  EventsAlarmTableViewCell.h
//  Safelet
//
//  Created by Mihai Eros on 10/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Alarm;
@class EventsAlarmTableViewCell;

@protocol EventsAlarmCellDelegate <NSObject>
- (void)alarmCellDidSelectSeeDetails:(EventsAlarmTableViewCell * _Nonnull)cell;
- (void)alarmCellDidSelectIgnoreAlarm:(EventsAlarmTableViewCell * _Nonnull)cell;
@end

@interface EventsAlarmTableViewCell : UITableViewCell

@property (strong, nonatomic) Alarm * _Nonnull alarm;
@property (weak, nonatomic) id  <EventsAlarmCellDelegate> _Nullable delegate;

- (void)populateWithAlarm:(Alarm * _Nonnull)alarm
                 delegate:(id <EventsAlarmCellDelegate> _Nullable)delegate;

+ (NSString * _Nonnull)identifier;
@end
