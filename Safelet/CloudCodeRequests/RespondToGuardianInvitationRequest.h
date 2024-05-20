//
//  RespondToGuardianInvitationRequest.h
//  Safelet
//
//  Created by Alex Motoc on 20/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"
#import "GuardianInvitationStatus.h"

/**
 *	Respond to an invitation sent from one user to the other. The available responses are: ACCEPTED and REJECTED
 *  The user that has been ACCEPTED/REJECTED as guardian will be notified by push notifications
 */
@interface RespondToGuardianInvitationRequest : BaseRequest

/**
 *	Request contructor. Upon success, returns the NSNumber @1. Upon error, returns the error object.
 *
 *	@param fromUser			NSString representing the objectId of the source user that sent the invitation
 *	@param toUser           NSString representing the objectId of  the destination user that received the invitation and now is responding to it
 *	@param invitationStatus	invitationStatus description
 *
 *	@return request instance
 */
+ (instancetype _Nonnull)requestWithFromUserObjectId:(NSString * _Nonnull)fromUser
                                      toUserObjectId:(NSString * _Nonnull)toUser
                                      responseStatus:(SLGuardianInvitationResponseType)responseType;

@end
