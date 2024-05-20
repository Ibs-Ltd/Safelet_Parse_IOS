//
//  GuardianInvitationStatus.h
//  Safelet
//
//  Created by Alex Motoc on 14/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#ifndef GuardianInvitationStatus_h
#define GuardianInvitationStatus_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SLGuardianInvitationResponseType) {
    SLGuardianInvitationResponseTypeAccepted,
    SLGuardianInvitationResponseTypeRejected
};

/**
 *	These are the statuses that you will receive in the "status" property of GuardianInvitaion.h by running a query on the Parse table.
 *  DO NOT MODIFY THESE VALUES ONLY IF YOU MODIFY THEM IN THE DATABASE AS WELL!!!
 */

#warning replace this with enum in GuardianInvitation.h; add getter for status

static NSString * const kGuardianInvitationStatusNone = @"none"; // no connection between these users
static NSString * const kGuardianInvitationStatusPending = @"pending"; // fromUser invited toUser
static NSString * const kGuardianInvitationStatusAccepted = @"accepted"; // toUser accepted the invitation
static NSString * const kGuardianInvitationStatusRejected = @"rejected"; // toUser rejected the invitation

#endif /* GuardianInvitationStatus_h */
