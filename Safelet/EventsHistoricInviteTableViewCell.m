//
//  EventsHistoricInviteTableViewCell.m
//  Safelet
//
//  Created by Alex Motoc on 14/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "GuardianInvitation.h"
#import "EventsHistoricInviteTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FormatterKit/TTTTimeIntervalFormatter.h>

@interface EventsHistoricInviteTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;
@end

@implementation EventsHistoricInviteTableViewCell

- (void)populateWithGuardianInvitation:(GuardianInvitation *)invitation {
//    TTTTimeIntervalFormatter *timeIntervalFormatter = [[TTTTimeIntervalFormatter alloc] init];
//    NSString *timeStamp = [timeIntervalFormatter stringForTimeInterval:invitation.updatedAt.timeIntervalSinceNow];
    self.titleLabel.text = [NSString stringWithFormat:@"%@%@%@", invitation.fromUser.name,
                            NSLocalizedString(@" invited you to be his guardian ", nil),
                            @""];
    
    if ([invitation.status isEqualToString:kGuardianInvitationStatusNone]) {
        self.detailsLabel.text = NSLocalizedString(@"Cancelled", nil);
    } else if ([invitation.status isEqualToString:kGuardianInvitationStatusAccepted]) {
        self.detailsLabel.text = NSLocalizedString(@"You accepted the invitation", nil);
    } else if ([invitation.status isEqualToString:kGuardianInvitationStatusRejected]) {
        self.detailsLabel.text = NSLocalizedString(@"You rejected the invitation", nil);
    } else {
        NSAssert(NO, @"INVALID STATUS: %@", invitation.status);
    }
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:invitation.fromUser.userImage.url]
                          placeholderImage:[UIImage imageNamed:@"generic_icon"]];
}

+ (NSString *)identifier {
    return @"historicInviteCell";
}

@end
