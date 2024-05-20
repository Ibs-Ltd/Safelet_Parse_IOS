//
//  checkCurrentFollowRequest.m
//  Safelet
//
//  Created by Ram on 02/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "checkCurrentFollowRequest.h"

@interface checkCurrentFollowRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@end

@implementation checkCurrentFollowRequest

+ (instancetype)checkCurrentFollow:(NSString *)aUserObjectId{
    
    checkCurrentFollowRequest *request = [self request];
    
    request.userObjectId = aUserObjectId;
    
    return request;
}

- (NSString *)requestURL {
    return @"checkCurrentFollow";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId
             };
}

@end
