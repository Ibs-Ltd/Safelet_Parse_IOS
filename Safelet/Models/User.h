//
//  User.h
//  Safelet
//
//  Created by Alex Motoc on 02/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@interface User : PFUser <PFSubclassing>

@property (strong, nonatomic) NSString *name; // the user's full address book name if available, otherwise the name stored on Parse
@property (strong, nonatomic) NSString *phoneNumber; // user's phone number
@property (strong, nonatomic) NSString *emergencyPhoneNumber; // phone number that will be called in case of an Alarm
@property (strong, nonatomic) NSString *locationName; // the user's current location name
@property (strong, nonatomic) PFGeoPoint *locationCoordinates; // user's current location in coordinates
@property (strong, nonatomic) PFFileObject *userImage; // user's profile image
@property (strong, nonatomic) NSString *phoneCountryCode; // the country code of the phone number the user registered
@property (nonatomic) BOOL isCommunityMember; // YES if the user is registered as a community guardian
@property (nonatomic) BOOL hasBracelet; // YES if the user is registered as a community guardian
@property (nonatomic) BOOL isTermsConditionAccepted; // YES if the user is accepted terms and condition

- (NSString *)phoneNumberWithoutCountryCode;
- (NSString *)originalName; // always returns the name stored on Parse

@end
