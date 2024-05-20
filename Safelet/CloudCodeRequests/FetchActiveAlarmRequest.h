//
//  FetchActiveAlarmRequest.h
//  Safelet
//
//  Created by Alex Motoc on 29/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface FetchActiveAlarmRequest : BaseRequest

/**
 *	Fetches the active alarm dispatched by a user. If no such alarm is found, return nil.
 *
 *	@param objectId	the objectId of the user that is dispatching the alarm
 *
 *	@return the active alarm associated with the provided user, 
 *          or nil if no active alarm was found for this user, 
 *          or the encountered error
 */
+ (instancetype _Nonnull)requestWithUserObjectId:(NSString * _Nonnull)objectId;

@end
