//
//  PhoneContact.h
//  Safelet
//
//  Created by Alex Motoc on 22/03/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PhoneContactStatus) {
    PhoneContactStatusNotMember, //not a safelet user
    PhoneContactStatusSMSInvited, // same as NotMember, but invited to become one via SMS
    PhoneContactStatusUninvited, // safelet user
    PhoneContactStatusInvited, // safelet user invited to become a Guardian
    PhoneContactStatusGuardian, // one of your guardians
    PhoneContactStatusOwnUser // this contact is the current user
};

static NSString * _Nonnull const kPhoneContactOptionUninvited = @"uninvited";
static NSString * _Nonnull const kPhoneContactOptionInvited = @"invited";
static NSString * _Nonnull const kPhoneContactOptionGuardian = @"guardian";

@class User;

@interface PhoneContact : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (strong, nonatomic, readonly) NSString *firstName;
@property (strong, nonatomic, readonly) NSString *lastName;
@property (strong, nonatomic, readonly) NSString *phoneNumber;
@property (strong, nonatomic, readonly) NSString *userObjectId; // parse obj id
@property (strong, nonatomic, readonly) NSString *imageURL;
@property (nonatomic, readonly) PhoneContactStatus status;

- (NSString *)formattedName;
- (BOOL)isParseUser;
- (void)updateStatus:(PhoneContactStatus)newStatus;

// Safelet non user constructor
- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                      phoneNumber:(NSString *)phoneNumber
                            image:(UIImage * _Nullable)image
                     isSMSInvited:(BOOL)smsInvited;

// convenience
- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                      phoneNumber:(NSString *)phoneNumber
                            image:(UIImage * _Nullable)image;

/**
 Safelet user constructor

 @param options represents the kind of parse user
 - kPhoneContactOptionMember: BOOL (default) - sets the PhoneContactStatus value to PhoneContactStatusMember
 - kPhoneContactOptionInvited: BOOL - sets the PhoneContactStatus value to PhoneContactStatusInvited
 - kPhoneContactOptionGuardian: BOOL - sets the PhoneContactStatus value to PhoneContactStatusGuardian
 @return a PhoneContact instance populated with the appropriate ParseContactStatus
 */
- (instancetype)initWithFirstName:(NSString *)firstName
                         lastName:(NSString *)lastName
                      phoneNumber:(NSString *)phoneNumber
                         imageURL:(NSString * _Nullable)imageURL
                      parseUserId:(NSString *)userId
                          options:(NSDictionary <NSString *, NSNumber *> * _Nullable)options;

NS_ASSUME_NONNULL_END

@end
