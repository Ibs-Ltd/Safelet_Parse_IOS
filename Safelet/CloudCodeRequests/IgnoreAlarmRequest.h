//
//  IgnoreAlarmRequest.h
//  Safelet
//
//  Created by Alex Motoc on 27/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface IgnoreAlarmRequest : BaseRequest

NS_ASSUME_NONNULL_BEGIN

/**
 *	Adds the current user to the alarm's ignoring list.
 *
 *	@param alarmObjId	the alarm objectId
 *
 *	@return return a boolean to indicate success or failure and the encountered error if any
 */
+ (instancetype)requestWithAlarmObjectId:(NSString *)alarmObjId;

NS_ASSUME_NONNULL_END

@end
