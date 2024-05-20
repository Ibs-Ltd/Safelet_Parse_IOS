//
//  StartFollowMeRequest.h
//  Safelet
//
//  Created by Ram on 01/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//
#import "BaseRequest.h"
@class PFGeoPoint;
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StartFollowMeRequest : BaseRequest


/**
 *    Start Follow Me to selected Guardians provided user object id
 *  This user's guardians will be notified via push notifications sent from the backend service.
 *
 *    @param objectId            the objectId of the user that is creating the check in
 *    @param geoPoint            the coordinates of the check in
 *    @param locationName     the name of the location described by the above coordinates
 *
 *    @return return a boolean value meaning that the request succeeded or failed, and the encountered error if any
 */

+ (instancetype _Nonnull)startFollowMeToGuardians:(NSString * _Nonnull)objectId
                                         checkInLocation:(PFGeoPoint * _Nonnull)geoPoint
                                          checkInAddress:(NSString * _Nonnull)locationName                                          
                                           selectedUsers:(NSArray * _Nullable)selectedUsers;

@end

NS_ASSUME_NONNULL_END
