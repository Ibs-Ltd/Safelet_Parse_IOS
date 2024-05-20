//
//  GetParseUsersForPhoneUsersRequest.m
//  Safelet
//
//  Created by Alex Motoc on 14/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "FetchParseUsersForPhoneUsers.h"

@interface FetchParseUsersForPhoneUsers ()
@property (strong, nonatomic) NSArray <NSString *> *phoneNumbers;
@end

@implementation FetchParseUsersForPhoneUsers

+ (instancetype)requestWithPhoneNumbers:(NSArray<NSString *> *)phoneNumbers {
    FetchParseUsersForPhoneUsers *request = [self request];
    request.phoneNumbers = phoneNumbers;
    return request;
}

- (NSString *)requestURL {
    return @"fetchParseUsersForPhoneUsers";
}

- (NSDictionary *)params {
   return @{@"phoneNumbers":self.phoneNumbers};
}

- (id)handleResponseData:(id)data {
    return [[MatchedParseUsers alloc] initFrom:data];
}

- (void)setRequestCompletionBlock:(void (^)(MatchedParseUsers *, NSError *))requestCompletionBlock {
    [super setRequestCompletionBlock:requestCompletionBlock];
}

@end
