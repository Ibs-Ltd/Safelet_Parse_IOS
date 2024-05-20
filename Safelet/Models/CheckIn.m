//
//  CheckIn.m
//  Safelet
//
//  Created by Alex Motoc on 02/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CheckIn.h"
#import <Parse/PFObject+Subclass.h>

static NSString * const kParseClassName = @"CheckIn";

@implementation CheckIn

@dynamic user;
@dynamic location;
@dynamic locationName;
@dynamic message;

+ (NSString *)parseClassName {
    return kParseClassName;
}

+ (void)load {
    [self registerSubclass];
}

@end
