//
//  EventsInviteTableViewCell.m
//  Safelet
//
//  Created by Mihai Eros on 10/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EventsInviteTableViewCell.h"
#import "GuardianInvitation.h"
#import "Utils.h"
#import "SLErrorHandlingController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FormatterKit/TTTTimeIntervalFormatter.h>

@interface EventsInviteTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *denyButton;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@end

@implementation EventsInviteTableViewCell

#pragma mark - Populate cell

- (void)populateWithUser:(GuardianInvitation *)invitation
                delegate:(id<EventsInviteCellDelegate>)delegate {
    self.guardianInvitation = invitation;
    self.delegate = delegate;
    
    NSString *detailsDescription = [invitation.fromUser.name stringByAppendingString:NSLocalizedString(@" invited you to be his guardian ",
                                                                                                       @"invitation description for EventsInviteTableViewCell")];
    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
    // in timeStamp
    NSString *timeStamp = [timeIntervalFormatter stringForTimeInterval:invitation.updatedAt.timeIntervalSinceNow];
    self.detailsLabel.text = [detailsDescription stringByAppendingString:timeStamp];
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:invitation.fromUser.userImage.url]
                           placeholderImage:[UIImage imageNamed:@"generic_icon"]];
    
}

+ (NSString *)identifier {
    return @"inviteCell";
}

#pragma mark - IBActions

- (IBAction)didTapAcceptButton:(id)sender {
    [self.delegate inviteCell:self didSelectStatus:SLGuardianInvitationResponseTypeAccepted];
}

- (IBAction)didTapDenyButton:(id)sender {
    [self.delegate inviteCell:self didSelectStatus:SLGuardianInvitationResponseTypeRejected];
}

@end
