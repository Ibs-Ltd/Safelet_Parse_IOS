//
//  FetchParticipantsRequest.h
//  Safelet
//
//  Created by Alex Motoc on 05/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface FetchParticipantsRequest : BaseRequest

/**
 *	Get list of participants for a given alarm
 *
 *	@param alarmObjId	the objectId of the alarm object we want to find paricipants for
 *
 *	@return upon success, return an array of User objects that are participating to this alarm, or the encountered error
 */
+ (instancetype _Nonnull)requestWithAlarmObjectId:(NSString * _Nonnull)alarmObjId;

@end
