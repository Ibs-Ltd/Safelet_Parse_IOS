//
//  CancelNonUserSMSInvitation.h
//  Safelet
//
//  Created by Alexandru Motoc on 04/12/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface CancelNonUserSMSInvitation : BaseRequest

+ (instancetype)requestWithPhoneNumber:(NSString *)phoneNumber;

@end
