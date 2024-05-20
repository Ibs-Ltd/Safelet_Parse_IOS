//
//  CheckIn.h
//  Safelet
//
//  Created by Alex Motoc on 02/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "User.h"
#import <Parse/Parse.h>

@interface CheckIn : PFObject <PFSubclassing>

@property (strong, nonatomic) User *user; // the user that checked-in
@property (strong, nonatomic) PFGeoPoint *location; // the check-in location
@property (strong, nonatomic) NSString *locationName; // check-in location name
@property (strong, nonatomic) NSString *message; // check-in message

@end
