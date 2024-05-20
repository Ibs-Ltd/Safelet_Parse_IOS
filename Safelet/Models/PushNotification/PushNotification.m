//
//  PushNotification.m
//
//  Created by Alex Motoc.
//  Copyright (c) 2014 Alex Motoc. All rights reserved.
//

#import "PushNotification.h"

@interface PushNotification ()
@property (strong, nonatomic) NSDictionary *sourceDict;
@end

@implementation PushNotification 

+ (instancetype)createFromDictionary:(NSDictionary *)dictionary {
    PushNotification *pushNotification = [self new];
    
    pushNotification.sourceDict = dictionary;
	pushNotification.objectId = dictionary[@"objectId"];
    pushNotification.className = dictionary[@"className"];
	
    return pushNotification;
}

+ (NSArray *)pushNotificationsArrayFromDictionaryArray:(NSArray *)dictionaryArray {
	NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaryArray) {
        [array addObject:[PushNotification createFromDictionary:dictionary]];
    }
    
    return array;
}

- (NSString *)defaultMessage {
    return self.sourceDict[@"message"] ?: @"";
}

- (NSString *)localizedKey {
    NSDictionary *aps = self.sourceDict[@"aps"];
    
    if ([aps[@"alert"] isKindOfClass:[NSString class]]) {
        return aps[@"alert"];
    } else if ([aps[@"alert"] isKindOfClass:[NSDictionary class]]) {
        return aps[@"alert"][@"loc-key"];
    }
    
    return nil;
}

- (NSArray *)localizedArgs {
    NSDictionary *aps = self.sourceDict[@"aps"];
    
    if ([aps[@"alert"] isKindOfClass:[NSDictionary class]]) {
        return aps[@"alert"][@"loc-args"];
    }
    
    return nil;
}

@end
