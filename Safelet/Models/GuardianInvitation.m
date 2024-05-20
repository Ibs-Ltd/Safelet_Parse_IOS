//
//  GuardianInvitation.m
//  Safelet
//
//  Created by Alex Motoc on 02/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "GuardianInvitation.h"
#import <Parse/PFObject+Subclass.h>

static NSString * const kParseClassName = @"GuardianInvitation";

@implementation GuardianInvitation

@dynamic fromUser;
@dynamic toUser;
@dynamic status;

#pragma mark - PFSubclassing

+ (NSString *)parseClassName {
    return kParseClassName;
}

+ (void)load {
    [self registerSubclass];
}

- (BOOL)isHistoric {
    return ![self.status isEqualToString:kGuardianInvitationStatusPending];
}

- (GuardianInvitationStatus)getInvitationStatus {
    if ([self.status isEqualToString:kGuardianInvitationStatusNone]) {
        return GuardianInvitationStatusNone;
    } else if ([self.status isEqualToString:kGuardianInvitationStatusPending]) {
        return GuardianInvitationStatusPending;
    } else if ([self.status isEqualToString:kGuardianInvitationStatusAccepted]) {
        return GuardianInvitationStatusAccepted;
    } else if ([self.status isEqualToString:kGuardianInvitationStatusRejected]) {
        return GuardianInvitationStatusRejected;
    } else {
        return GuardianInvitationStatusNone;
    }
}

@end
