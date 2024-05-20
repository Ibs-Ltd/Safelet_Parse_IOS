//
//  SLUserDefaults.m
//  Safelet
//
//  Created by Alex Motoc on 26/01/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SLUserDefaults.h"
#import <CommonCrypto/CommonCrypto.h>

static NSString * const kLastUsedEmailKey = @"lastUsedEmail";
static NSString * const kHashedPasswordKey = @"hashedPassword";

@implementation SLUserDefaults

+ (NSString *)previouslyUsedEmail {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLastUsedEmailKey] ?: @"";
}

+ (void)setPreviouslyUsedEmail:(NSString *)email {
    [[NSUserDefaults standardUserDefaults] setObject:email forKey:kLastUsedEmailKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
