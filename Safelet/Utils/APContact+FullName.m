//
//  APContact+FullName.m
//  Safelet
//
//  Created by Mihai Eros on 11/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "APContact+FullName.h"

@implementation APContact (FullName)

- (NSString *)fullName {
    return self.name.compositeName;
}

@end
