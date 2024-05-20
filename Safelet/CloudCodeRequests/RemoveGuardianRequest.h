//
//  RemoveGuardianRequest.h
//  Safelet
//
//  Created by Alex Motoc on 20/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

/**
 *	Remove the guardian/guarded status between 2 users. 
 *  The user that has been removed as guardian will be notified by push notifications
 */
@interface RemoveGuardianRequest : BaseRequest

/**
 *	Request contructor. Upon success, returns the NSNumber @1. Upon error, returns the error object.
 *
 *	@param fromUser     NSString representing the objectId of the source user that firstly sent the invitation, but now wants to remove it
 *	@param toUser		NSString representing the objectId of  the destination user that received the invitation and accepted it
 *  @param initiator        NSString representing the objectID of user who initiated the remove request (should be equal to fromUser or toUser)
 *                          helpful for determinig the message sent as push notification, and the person who will receive it
 *
 *	@return request instance
 */
+ (instancetype _Nonnull)requestWithFromUserObjectId:(NSString * _Nonnull)fromUser
                                      toUserObjectId:(NSString * _Nonnull)toUser
                               initiatorUserObjectId:(NSString * _Nonnull)initiator;

@end
