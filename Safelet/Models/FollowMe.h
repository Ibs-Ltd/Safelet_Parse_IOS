//
//  FollowMe.h
//  Safelet
//
//  Created by Ram on 03/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@class PFGeoPoint;
#import <Parse/Parse.h>

typedef NS_ENUM(NSUInteger, FollowMeStatus) {
    FollowMeStatusStartFollow,
    FollowMeStatusStopFollowMe,
    FollowMeStatusStopFollowUser
};


NS_ASSUME_NONNULL_BEGIN

@interface FollowMe : PFObject <PFSubclassing>

@property (strong, nonatomic) PFGeoPoint *location; // user that initiated the invitation
@property (strong, nonatomic) NSString *locationName; // invitation's destination user
// the status of the invitation. is of type kGuardianInvitationStatus, declared in GuardianInvitationStatus.h
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSArray *selected_guardians;
@property (strong, nonatomic) User *user;

- (FollowMeStatus)getFollowMeStatus;


@end

NS_ASSUME_NONNULL_END
