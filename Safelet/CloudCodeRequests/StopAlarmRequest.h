//
//  StopAlarmRequest.h
//  Safelet
//
//  Created by Alex Motoc on 04/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"
#import "StopAlarmReason.h"

@interface StopAlarmRequest : BaseRequest

/**
 *	Stops an alarm by setting its property "isActive" to false.
 *  Participants will be informed via push notifications sent from the backend
 *
 *	@param alarmObjId	the objectId of the alarm we want to stop
 *
 *	@return return a boolean to indicate success or failure and the encountered error if any
 */
+ (instancetype _Nonnull)requestWithAlarmObjectId:(NSString * _Nonnull)alarmObjId
                                       stopReason:(StopReason)reason
                                reasonDescription:(NSString * _Nullable)reasonDescription;

@end
