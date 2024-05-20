//
//  CheckIfUserExistsRequest.h
//  Safelet
//
//  Created by Alex Motoc on 14/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface CheckIfUserExistsRequest : BaseRequest

/**
 *	Check if a username is already registered in Parse
 *
 *	@param username	NSString * username of a user
 *
 *	@return - RequestCompletionBlock - on success response = NSNumber * with value 0 if the username is not registered in the app, or 1 if the username exists
 *                                   - on error response = nil, error = the error object
 */
+ (instancetype _Nonnull)requestWithUsername:(NSString * _Nonnull)username;

@end
