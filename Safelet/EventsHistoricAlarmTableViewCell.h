//
//  EventsHistoricAlarmTableViewCell.h
//  Safelet
//
//  Created by Alex Motoc on 14/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Alarm;
@class EventsHistoricAlarmTableViewCell;

@protocol EventsHistoricAlarmCellDelegate <NSObject>
- (void)historicAlarmCellDidSelectPlayRecordingForAlarm:(Alarm * _Nonnull)alarm;
@end

@interface EventsHistoricAlarmTableViewCell : UITableViewCell

- (void)populateWithAlarm:(Alarm * _Nonnull)alarm
                 delegate:(id <EventsHistoricAlarmCellDelegate> _Nullable)delegate;

+ (NSString * _Nonnull)identifier;

@end
