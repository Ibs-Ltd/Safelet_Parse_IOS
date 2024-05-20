//
//  FetchLastCheckInForUserRequest.h
//  Safelet
//
//  Created by Alex Motoc on 28/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface FetchLastCheckInForUserRequest : BaseRequest

/**
 *	Retrieves the most recent check-in a user has created
 *
 *	@param userObjId	the user we want to get the most recent check in
 *
 *	@return upon success, return the most recent check in; otherwise return the encountered error
 */
+ (instancetype)requestWithUserObjectId:(NSString *)userObjId;

@end
