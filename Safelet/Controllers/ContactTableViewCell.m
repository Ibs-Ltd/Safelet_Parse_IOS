//
//  ContactTableViewCell.m
//  Safelet
//
//  Created by Alex Motoc on 08/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "ContactTableViewCell.h"
#import "PhoneContact.h"
#import "SLContactsUIManager.h"
#import "User.h"
#import "GuardianInvitationStatus.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ContactTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *noNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *requestAsGuardianButton;
@property (strong, nonatomic) PhoneContact *phoneContact;
@property (nonatomic) BOOL isCancelMode;
@end

@implementation ContactTableViewCell

+ (CGFloat)heightForContact:(PhoneContact *)contact {
    if ([contact.userObjectId isEqualToString:[User currentUser].objectId] || contact.status == PhoneContactStatusGuardian) {
        return 90;
    }
    return 143;
}

#pragma mark - Initializations

- (void)awakeFromNib {
    [super awakeFromNib];
    self.requestAsGuardianButton.layer.masksToBounds = YES;
    self.requestAsGuardianButton.layer.cornerRadius = 5.0f;
}

- (void)populateWithPhoneContact:(PhoneContact *)contact
                        delegate:(id<ContactTableViewCellDelegate>)delegate {
    self.phoneContact = contact;
    self.delegate = delegate;
    NSString *name = [contact formattedName];
    
    if (name.length == 0) {
        self.userNameLabel.hidden = YES;
        self.noNameLabel.hidden = NO;
    } else {
        self.userNameLabel.text = name;
        self.userNameLabel.hidden = NO;
        self.noNameLabel.hidden = YES;
    }
    
    self.phoneNumberLabel.text = contact.phoneNumber;
    self.userStatusLabel.textColor = [UIColor darkGrayColor];
    
    self.userStatusLabel.text = [self userStatusTextForStatus:contact.status];
    if (contact.status == PhoneContactStatusOwnUser || contact.status == PhoneContactStatusGuardian) {
        self.requestAsGuardianButton.hidden = YES;
        if (contact.status == PhoneContactStatusGuardian) {
            self.userStatusLabel.textColor = [UIColor colorWithRed:65.0f/255.0f green:122.0f/255.0f blue:0 alpha:1];
        }
        return;
    }
    
    self.isCancelMode = contact.status == PhoneContactStatusSMSInvited || contact.status == PhoneContactStatusInvited;
    [self setRequestGuardianButtonUI:self.isCancelMode];
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:contact.imageURL]
                          placeholderImage:[UIImage imageNamed:@"generic_icon"]];
}

#pragma makr - User Interaction

- (IBAction)didTapRequestAsGuardian:(UIButton *)sender {
    if (self.isCancelMode) {
        [self.delegate contactsCellDidSelectCancelGuardianRequest:self.phoneContact];
        return;
    }
    [self.delegate contactsCellDidSelectRequestGuardian:self.phoneContact];
}

#pragma mark - Utils
- (NSString *)userStatusTextForStatus:(PhoneContactStatus)status {
    switch (status) {
        case PhoneContactStatusUninvited:
            return NSLocalizedString(@"Not requested as guardian", nil);
        case PhoneContactStatusInvited:
            return NSLocalizedString(@"Requested as guardian", nil);
        case PhoneContactStatusGuardian:
            return NSLocalizedString(@"Is your guardian", nil);
        case PhoneContactStatusSMSInvited:
            return NSLocalizedString(@"Invited via SMS", nil);
        case PhoneContactStatusNotMember:
            return NSLocalizedString(@"Not a member", nil);
        case PhoneContactStatusOwnUser:
            return NSLocalizedString(@"Own user", nil);
    }
}

- (void)setRequestGuardianButtonUI:(BOOL)cancelRequest {
    self.requestAsGuardianButton.hidden = NO;
    if (cancelRequest) {
        self.requestAsGuardianButton.layer.borderWidth = 1.0f;
        self.requestAsGuardianButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.requestAsGuardianButton.backgroundColor = [UIColor clearColor];
        [self.requestAsGuardianButton setTitle:NSLocalizedString(@"Cancel guardian request", nil) forState:UIControlStateNormal];
        [self.requestAsGuardianButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    } else {
        self.requestAsGuardianButton.layer.borderWidth = 0;
        self.requestAsGuardianButton.layer.borderColor = [[UIColor clearColor] CGColor];
        self.requestAsGuardianButton.backgroundColor = [UIColor colorWithRed:208.0f/255.0f green:2.0f/255.0f blue:27.0f/255.0f alpha:1];
        [self.requestAsGuardianButton setTitle:NSLocalizedString(@"Request as guardian", nil) forState:UIControlStateNormal];
        [self.requestAsGuardianButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

@end
