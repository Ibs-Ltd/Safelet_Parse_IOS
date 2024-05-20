//
//  StopFollowMeRequest.h
//  Safelet
//
//  Created by Ram on 02/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//
#import "BaseRequest.h"
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface StopFollowMeRequest : BaseRequest

/**
 *    Stop Follow Me guardians by follow me object id
 *  This user's guardians will be notified via push notifications sent from the backend service.
 *
 *    @param objectId            the objectId of the follow me request that is creating the check in
 *    @param geoPoint            the coordinates of the check in
 *    @param locationName     the name of the location described by the above coordinates
 *
 *    @return return a boolean value meaning that the request succeeded or failed, and the encountered error if any
 */

+ (instancetype _Nonnull)stopFollowMe:(NSString * _Nonnull)objectId
                             followMeObjectId:(NSString * _Nonnull)followMeObjectId;



@end

NS_ASSUME_NONNULL_END
