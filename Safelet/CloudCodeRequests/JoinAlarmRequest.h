//
//  JoinAlarmRequest.h
//  Safelet
//
//  Created by Alex Motoc on 04/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface JoinAlarmRequest : BaseRequest

NS_ASSUME_NONNULL_BEGIN

/**
 *	Adds a user as participant to an alarm.
 *
 *	@param userObjId	the objectId of a user that wants to join an alarm as participant
 *	@param alarmObjId	the alarm objectId
 *
 *	@return return a boolean to indicate success or failure and the encountered error if any
 */
+ (instancetype)requestWithUserObjectId:(NSString *)userObjId
                          alarmObjectId:(NSString *)alarmObjId;
NS_ASSUME_NONNULL_END

@end
