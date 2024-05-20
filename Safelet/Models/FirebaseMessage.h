//
//  FirebaseMessage.h
//  Safelet
//
//  Created by Alexandru Motoc on 27/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "User.h"
#import <Foundation/Foundation.h>

@interface FirebaseMessage : NSObject

@property (strong, nonatomic) User *sender;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *imageURL;
@property (nonatomic) NSTimeInterval timestamp;

+ (instancetype)messageFromUser:(User *)user withText:(NSString *)text;
+ (instancetype)createFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;
@end
