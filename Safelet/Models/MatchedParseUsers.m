//
//  MatchedParseUsers.m
//  Safelet
//
//  Created by Alexandru Motoc on 03/12/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "MatchedParseUsers.h"

@implementation MatchedParseUsers

- (instancetype)initFrom:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _uninvited = dictionary[@"parse_uninvited"];
        _invited = dictionary[@"parse_invited"];
        _guardians = dictionary[@"parse_guardians"];
        _smsInvited = dictionary[@"sms_invited"];
        _unmatched = dictionary[@"unmatched"];
    }
    return self;
}

@end
