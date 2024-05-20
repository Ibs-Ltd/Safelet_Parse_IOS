//
//  EventsInviteTableViewCell.h
//  Safelet
//
//  Created by Mihai Eros on 10/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "GuardianInvitationStatus.h"
#import <UIKit/UIKit.h>

@class EventsInviteTableViewCell;
@class GuardianInvitation;

/**
 *  EventsInviteCellDelegate protocol was created in order to notify the EventsTableVC
 *  when it is safe to deleteRowsAtIndexPaths:withRowAnimation:.
 *  In order to aceive this goal protocol requires inviteCellDidChangeStatus:inviteCell
 *  to be implemented by the class that conforms to this delegate.
 */

@protocol EventsInviteCellDelegate <NSObject>
- (void)inviteCell:(EventsInviteTableViewCell * _Nonnull)inviteCell
   didSelectStatus:(SLGuardianInvitationResponseType)status;
@end

@interface EventsInviteTableViewCell : UITableViewCell

@property (weak, nonatomic) id <EventsInviteCellDelegate> _Nullable delegate;
@property (strong, nonatomic) GuardianInvitation * _Nonnull guardianInvitation;

- (void)populateWithUser:(GuardianInvitation * _Nonnull)invitation
                delegate:(id <EventsInviteCellDelegate> _Nullable)delegate;

+ (NSString * _Nonnull)identifier;

@end
