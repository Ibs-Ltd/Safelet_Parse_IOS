//
//  FetchParseUsersForPhoneUsersRequest.h
//  Safelet
//
//  Created by Alex Motoc on 14/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"
#import "MatchedParseUsers.h"

@interface FetchParseUsersForPhoneUsers : BaseRequest
+ (instancetype)requestWithPhoneNumbers:(NSArray<NSString *> *)phoneNumbers;
- (void)setRequestCompletionBlock:(void(^)(MatchedParseUsers *response, NSError *error))requestCompletionBlock;
@end
