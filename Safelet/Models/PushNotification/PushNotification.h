//
//  PushNotification.h
//
//  Created by Alex Motoc.
//  Copyright (c) 2014 Alex Motoc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotification : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *className;

+ (instancetype)createFromDictionary:(NSDictionary *)dictionary;
+ (NSArray *)pushNotificationsArrayFromDictionaryArray:(NSArray *)dictionaryArray;

- (NSString *)localizedKey;
- (NSArray *)localizedArgs;
- (NSString *)defaultMessage;

@end
