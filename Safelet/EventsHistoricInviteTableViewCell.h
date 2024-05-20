//
//  EventsHistoricInviteTableViewCell.h
//  Safelet
//
//  Created by Alex Motoc on 14/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GuardianInvitation;

@interface EventsHistoricInviteTableViewCell : UITableViewCell
- (void)populateWithGuardianInvitation:(GuardianInvitation * _Nonnull)invitation;
+ (NSString * _Nonnull)identifier;
@end
