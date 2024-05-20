//
//  SendNonUserSMSInvitation.h
//  Safelet
//
//  Created by Alex Motoc on 01/02/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface SendNonUserSMSInvitation : BaseRequest

NS_ASSUME_NONNULL_BEGIN

/**
 *  A non user invitation is created when a user invites a phone contact to join Safelet via SMS.
 *  A non user invitation is unique.
 *
 *  When a user is created, for each NonUserInvitation he received, create actual GuardianInvitation
 *  objects having the just-created user as "toUser" and "status" = "pending", such that the
 *  invitations will appear in the user's Events feed
 *
 *  @param      senderObjId - obj id of the user that sent the invitation
 *              phoneNumber - the phone number to which the invitation was sent
 *  @param response on success: returns the NonUserInvitation object
 *                  on error:   returns the error message
 *
 *  @return instance to request object
 **/

+ (instancetype)requestWithSenderObjectId:(NSString *)senderObjId
                      receiverPhoneNumber:(NSString *)phoneNumber;
NS_ASSUME_NONNULL_END
@end
