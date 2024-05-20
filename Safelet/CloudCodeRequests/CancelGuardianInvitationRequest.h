//
//  CancelGuardianInvitationRequest.h
//  Safelet
//
//  Created by Alex Motoc on 20/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

/**
 *	Cancel an invitation sent from one user to the other.
 *  The user who was invited but then cancelled will be notified by push notifications
 */
@interface CancelGuardianInvitationRequest : BaseRequest

/**
 *	Request contructor. Upon success returns the NSNumber @1. Upon error returns the error object.
 *
 *	@param fromUser     NSString representing the objectId of the source user that sent the invitation and now cancels it
 *	@param toUser		NSString representing the objectId of the destination user that received the invitation which is now cancelled
 *
 *	@return request instance
 */
+ (instancetype _Nonnull)requestWithFromUserObjectId:(NSString * _Nonnull)fromUser
                                      toUserObjectId:(NSString * _Nonnull)toUser;

@end
