//
//  checkCurrentFollowRequest.h
//  Safelet
//
//  Created by Ram on 02/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//
#import "BaseRequest.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface checkCurrentFollowRequest : BaseRequest


/**
 *    Check current Follow request for login user id
 *  This user's guardians will be notified via push notifications sent from the backend service.
 *
 *    @param aUserObjectId            the aUserObjectId of the user
 *
 *    @return return a boolean value meaning that the request succeeded or failed, and the encountered error if any
 */

+ (instancetype _Nonnull)checkCurrentFollow:(NSString * _Nonnull)aUserObjectId;

@end

NS_ASSUME_NONNULL_END
