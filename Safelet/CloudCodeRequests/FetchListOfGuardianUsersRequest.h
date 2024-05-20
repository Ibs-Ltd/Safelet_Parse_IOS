//
//  FetchListOfGuardianUsersRequest.h
//  Safelet
//
//  Created by Alex Motoc on 22/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

/**
 *	Returns the list of guardians for a given user, or the encountered error
 */
@interface FetchListOfGuardianUsersRequest : BaseRequest

/**
 *	Request constructor
 *
 *	@param userObjectId	the objectId of the User object we want to find his guardians
 *
 *	@return request instance
 */
+ (instancetype _Nonnull)requestWithUserObjectId:(NSString * _Nonnull)userObjectId;

@end
