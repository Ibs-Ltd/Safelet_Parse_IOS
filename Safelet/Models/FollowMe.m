//
//  FollowMe.m
//  Safelet
//
//  Created by Ram on 03/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "FollowMe.h"
#import <Parse/PFObject+Subclass.h>

static NSString * const kParseClassName = @"FollowMe";

@implementation FollowMe

@dynamic location;
@dynamic locationName;
@dynamic status;
@dynamic user;
@dynamic selected_guardians;

#pragma mark - PFSubclassing

+ (NSString *)parseClassName {
    return kParseClassName;
}

+ (void)load {
    [self registerSubclass];
}

- (FollowMeStatus)getFollowMeStatus{
    return FollowMeStatusStartFollow;
}
@end
