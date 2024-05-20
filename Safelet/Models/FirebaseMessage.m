//
//  FirebaseMessage.m
//  Safelet
//
//  Created by Alexandru Motoc on 27/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "FirebaseMessage.h"

@interface FirebaseMessage ()
@end

@implementation FirebaseMessage

+ (instancetype)messageFromUser:(User *)user withText:(NSString *)text {
    FirebaseMessage *message = [self new];
    
    message.sender = user;
    message.imageURL = user.userImage.url ?: @"";
    message.text = text;
    message.timestamp = [[NSDate date] timeIntervalSince1970];
    
    return message;
}

+ (instancetype)createFromDictionary:(NSDictionary *)dictionary {
    FirebaseMessage *message = [self new];
    
    message.sender = [User objectWithoutDataWithObjectId:dictionary[@"sender"][@"id"]];
    message.sender.name = dictionary[@"sender"][@"name"] ?: @"";
    message.sender.phoneNumber = dictionary[@"sender"][@"number"] ?: @"";
    message.imageURL = dictionary[@"sender"][@"image"] ?: @"";
    message.text = dictionary[@"text"];
    
    long long rawTimestamp = [((NSNumber *)dictionary[@"timestamp"]) longLongValue];
    NSTimeInterval timestamp = (double)((double)rawTimestamp / 1000.0f);
    message.timestamp = timestamp;
    
    return message;
}

- (NSDictionary *)toDictionary {
    NSDictionary *sender = @{
                             @"id":self.sender.objectId,
                             @"name":[self.sender originalName],
                             @"number":self.sender.phoneNumber,
                             @"image":self.imageURL ?: @""
                             };
    
    return @{
             @"sender":sender,
             @"text":self.text,
             @"timestamp":@(llrint(self.timestamp * 1000.0f))
            };
}

@end
