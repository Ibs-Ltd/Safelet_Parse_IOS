//
//  User.m
//  Safelet
//
//  Created by Alex Motoc on 02/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "User.h"
#import "SLDataManager.h"
#import "PhoneContact.h"
#import "Utils.h"
#import <Parse/PFObject+Subclass.h>

@implementation User

@dynamic name;
@dynamic phoneNumber;
@dynamic emergencyPhoneNumber;
@dynamic locationName;
@dynamic locationCoordinates;
@dynamic userImage;
@dynamic isCommunityMember;
@dynamic phoneCountryCode;
@dynamic hasBracelet;
@dynamic isTermsConditionAccepted;

- (void)setName:(NSString *)name {
    [self setObject:name forKey:@"name"];
}

- (NSString *)name {
    NSString *contactName = [SLDataManager sharedManager].phoneContactsSimple[self.phoneNumber];
    if (contactName.length == 0) {
        return [self objectForKey:@"name"];
    }
    
    return contactName;
}

- (NSString *)originalName {
    return [self objectForKey:@"name"];
}

#pragma mark - PFSubclassing

/**
 *	There is no need to override the +parseClassName method because it is already implemented in PFUser
 */

+ (void)load {
    [self registerSubclass];
}

- (NSString *)phoneNumberWithoutCountryCode {
    return [self.phoneNumber stringByReplacingOccurrencesOfString:self.phoneCountryCode
                                                       withString:@""];
}

@end
