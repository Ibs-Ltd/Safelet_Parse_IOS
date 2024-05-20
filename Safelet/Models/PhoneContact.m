//
//  PhoneContact.m
//  Safelet
//
//  Created by Alex Motoc on 22/03/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "PhoneContact.h"
#import "User.h"

@interface PhoneContact ()
@end

@implementation PhoneContact

#pragma mark - Logic

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                      phoneNumber:(NSString *)phoneNumber
                            image:(UIImage *)image {
    return [self initWithFirstName:firstName lastName:lastName phoneNumber:phoneNumber image:image isSMSInvited:NO];
}

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                      phoneNumber:(NSString *)phoneNumber
                            image:(UIImage *)image
                     isSMSInvited:(BOOL)smsInvited {
    self = [super init];
    if (self) {
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumber = phoneNumber;
        _imageURL = [PhoneContact imageURLFromImage:image];
        _status = smsInvited ? PhoneContactStatusSMSInvited : PhoneContactStatusNotMember;
    }
    return self;
}

- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                      phoneNumber:(NSString *)phoneNumber
                         imageURL:(NSString *)imageURL
                      parseUserId:(NSString *)userId
                          options:(NSDictionary<NSString *,NSNumber *> *)options {
    self = [super init];
    if (self) {
        _firstName = firstName;
        _lastName = lastName;
        _phoneNumber = phoneNumber;
        _imageURL = imageURL;
        _userObjectId = userId;
        
        if (options[kPhoneContactOptionGuardian]) {
             _status = PhoneContactStatusGuardian;
        } else if (options[kPhoneContactOptionInvited]) {
            _status = PhoneContactStatusInvited;
        } else if ([[User currentUser].objectId isEqualToString:userId]) {
            _status = PhoneContactStatusOwnUser;
        } else {
            _status = PhoneContactStatusUninvited;
        }
    }
    return self;
}

- (void)updateStatus:(PhoneContactStatus)newStatus {
    BOOL isParse = [self isParseUser];
    BOOL statusIsParse = [self statusIsParseUser:newStatus];
    
    if (isParse) {
        NSAssert(statusIsParse,
                 @"Can't change a parse user in status NotMember or SMSInvited; curr: %ld, newVal: %ld", _status, newStatus);
    } else {
        NSAssert(statusIsParse == NO,
                 @"Can't change status NotMember or SMSInvited to parse user (Member, etc.); curr: %ld, newVal: %ld", _status, newStatus);
    }
    
    _status = newStatus;
}

- (BOOL)isParseUser {
    return [self statusIsParseUser:self.status];
}

- (NSString *)formattedName {
    if (self.firstName.length == 0 && self.lastName == 0) {
        return @"";
    } else if (self.firstName.length == 0) {
        return self.lastName;
    } else if (self.lastName.length == 0) {
        return self.firstName;
    }
    
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

#pragma mark - Utils

- (BOOL)statusIsParseUser:(PhoneContactStatus)status {
    return status == PhoneContactStatusUninvited ||
    status == PhoneContactStatusInvited ||
    status == PhoneContactStatusGuardian;
}

+ (NSString *)imageURLFromImage:(UIImage *)image {
    NSError *err = nil;
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"contact_image_%f.png", [NSDate date].timeIntervalSince1970]];
    
    [UIImagePNGRepresentation(image) writeToFile:path options:NSDataWritingAtomic error:&err];
    
    if (image != nil && err == nil) {
        return [NSURL fileURLWithPath:path].absoluteString;
    }
    return nil;
}

@end
