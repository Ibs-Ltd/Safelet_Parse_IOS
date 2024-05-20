//
//  SendCheckInRequest.h
//  Safelet
//
//  Created by Alex Motoc on 29/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@class PFGeoPoint;
@interface CreateCheckInRequest : BaseRequest

/**
 *	Request for creating a check in for a provided user object id
 *  This user's guardians will be notified via push notifications sent from the backend service.
 *
 *	@param objectId			the objectId of the user that is creating the check in
 *	@param geoPoint			the coordinates of the check in
 *	@param locationName     the name of the location described by the above coordinates
 *	@param message			the check in message
 *
 *	@return return a boolean value meaning that the request succeeded or failed, and the encountered error if any
 */
+ (instancetype _Nonnull)requestWithUserObjectId:(NSString * _Nonnull)objectId
                                 checkInLocation:(PFGeoPoint * _Nonnull)geoPoint
                                  checkInAddress:(NSString * _Nonnull)locationName
                                  checkInMessage:(NSString * _Nullable)message;

@end
