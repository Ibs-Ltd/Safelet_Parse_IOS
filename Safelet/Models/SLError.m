//
//  SLError.m
//  Safelet
//
//  Created by Alex Motoc on 05/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SLError.h"

@implementation SLError

+ (NSError *)errorWithCode:(SLErrorCode)code failureReason:(NSString *)failure {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: failure};
    return [NSError errorWithDomain:SLSafeletErrorDomain code:code userInfo:userInfo];
}

@end
