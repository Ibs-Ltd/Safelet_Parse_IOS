//
//  GuardianInvitation.h
//  Safelet
//
//  Created by Alex Motoc on 02/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "User.h"
#import "GuardianInvitationStatus.h"
#import <Parse/Parse.h>

typedef NS_ENUM(NSUInteger, GuardianInvitationStatus) {
    GuardianInvitationStatusNone,
    GuardianInvitationStatusPending,
    GuardianInvitationStatusAccepted,
    GuardianInvitationStatusRejected
};

/**
 *	A class that models interactions between users. A user can invite another user to be his guardian,
 *  an reject an invitation or revoke a connection.
 */
@interface GuardianInvitation : PFObject <PFSubclassing>

@property (strong, nonatomic) User *fromUser; // user that initiated the invitation
@property (strong, nonatomic) User *toUser; // invitation's destination user
// the status of the invitation. is of type kGuardianInvitationStatus, declared in GuardianInvitationStatus.h
@property (strong, nonatomic) NSString *status;

- (BOOL)isHistoric;
- (GuardianInvitationStatus)getInvitationStatus;

@end
