//
//  CancelNonUserSMSInvitation.m
//  Safelet
//
//  Created by Alexandru Motoc on 04/12/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "CancelNonUserSMSInvitation.h"

@interface CancelNonUserSMSInvitation()
@property (strong, nonatomic) NSString *phoneNumber;
@end

@implementation CancelNonUserSMSInvitation

+ (instancetype)requestWithPhoneNumber:(NSString *)phoneNumber {
    CancelNonUserSMSInvitation *inv = [self request];
    inv.phoneNumber = phoneNumber;
    return inv;
}

- (NSString *)requestURL {
    return @"removeNonUserSMSInvitation";
}

- (NSDictionary *)params {
    return @{@"phoneNumber":self.phoneNumber};
}

@end
