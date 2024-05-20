//
//  SelectedUsersCheckIn.h
//  Safelet
//
//  Created by Ram on 08/02/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"
@class PFGeoPoint;

@interface SelectedUsersCheckIn : BaseRequest


/**
 *    Request for creating a check in for a provided user object id
 *  This user's guardians will be notified via push notifications sent from the backend service.
 *
 *    @param objectId            the objectId of the user that is creating the check in
 *    @param geoPoint            the coordinates of the check in
 *    @param locationName     the name of the location described by the above coordinates
 *    @param message            the check in message
 *
 *    @return return a boolean value meaning that the request succeeded or failed, and the encountered error if any
 */

+ (instancetype _Nonnull)requestWithUserObjectIdMultiple:(NSString * _Nonnull)objectId
                                         checkInLocation:(PFGeoPoint * _Nonnull)geoPoint
                                          checkInAddress:(NSString * _Nonnull)locationName
                                          checkInMessage:(NSString * _Nullable)message
                                           selectedUsers:(NSArray * _Nullable)selectedUsers;

@end
