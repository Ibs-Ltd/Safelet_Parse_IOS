//
//  SendInvitationRequest.h
//  Safelet
//
//  Created by Alex Motoc on 20/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

/**
 *	Send an invitation from a User to another User to become his guardian.
 *  The other user will be notified by push notificaitons.
 */

@interface SendGuardianInvitationRequest : BaseRequest

/**
 *	Request contructor. Upon success returns the NSNumber @1. Upon error returns the error object.
 *
 *	@param fromUser     NSString representing the objectId of the source user that is sending the invitation
 *	@param toUser		NSString representing the objectId of the destination user that will receive the invitation
 *
 *	@return request instance
 */
+ (instancetype _Nonnull)requestWithFromUserObjectId:(NSString * _Nonnull)fromUser
                                      toUserObjectId:(NSString * _Nonnull)toUser;

@end
