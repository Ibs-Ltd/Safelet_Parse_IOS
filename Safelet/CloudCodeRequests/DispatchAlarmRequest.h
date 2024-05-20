//
//  DispatchAlarmRequest.h
//  Safelet
//
//  Created by Alex Motoc on 29/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface DispatchAlarmRequest : BaseRequest

/**
 *	Dispatch an alarm and associate it with the dispatcher user.
 *  The guardians of this dispatcher will be notified through push notifications
 *
 *	@param objectId	the objectId of the User object which dispatched the alarm
 *
 *	@return upon success, return the Alarm object that was just created, or the encountered error
 */
+ (instancetype _Nonnull)requestWithUserObjectId:(NSString * _Nonnull)objectId;

@end
