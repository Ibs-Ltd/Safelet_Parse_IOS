//
//  CheckIfUserExistsRequest.m
//  Safelet
//
//  Created by Alex Motoc on 14/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CheckIfUserExistsRequest.h"

@interface CheckIfUserExistsRequest ()
@property (strong, nonatomic) NSString *username;
@end

@implementation CheckIfUserExistsRequest

+ (instancetype)requestWithUsername:(NSString *)username {
    CheckIfUserExistsRequest *request = [self request];
    
    request.username = username;
    
    return request;
}

- (NSString *)requestURL {
    return @"checkIfUserExists";
}

- (NSDictionary *)params {
    return @{@"username":self.username};
}

@end
