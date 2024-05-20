//
//  SendNonUserSMSInvitation.m
//  Safelet
//
//  Created by Alex Motoc on 01/02/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SendNonUserSMSInvitation.h"

@interface SendNonUserSMSInvitation ()
@property (strong, nonatomic) NSString *senderObjectId;
@property (strong, nonatomic) NSString *receiverPhoneNumber;
@end

@implementation SendNonUserSMSInvitation

+ (instancetype)requestWithSenderObjectId:(NSString *)senderObjId
                      receiverPhoneNumber:(NSString *)phoneNumber {
    SendNonUserSMSInvitation *request = [self request];
    
    request.senderObjectId = senderObjId;
    request.receiverPhoneNumber = phoneNumber;
    
    return request;
}

- (NSString *)requestURL {
    return @"createNonUserSMSInvitation";
}

- (NSDictionary *)params {
    return @{
             @"aUserObjectId": self.senderObjectId,
             @"phoneNumber": self.receiverPhoneNumber
             };
}

@end
