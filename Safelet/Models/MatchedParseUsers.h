//
//  MatchedParseUsers.h
//  Safelet
//
//  Created by Alexandru Motoc on 03/12/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "User.h"
#import <Foundation/Foundation.h>

@interface MatchedParseUsers : NSObject

@property (strong, nonatomic) NSDictionary <NSString *, User *> *uninvited;
@property (strong, nonatomic) NSDictionary <NSString *, User *> *invited;
@property (strong, nonatomic) NSDictionary <NSString *, User *> *guardians;
@property (strong, nonatomic) NSArray <NSString *> *smsInvited;
@property (strong, nonatomic) NSArray <NSString *> *unmatched;

- (instancetype)initFrom:(NSDictionary *)dictionary;

@end
