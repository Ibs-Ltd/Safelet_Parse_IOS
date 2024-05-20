//
//  NSException+NSError.m
//  Safelet
//
//  Created by Alexandru Motoc on 13/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SLError.h"
#import "NSException+NSError.h"

@implementation NSException (NSError)

- (NSError *)toError {
    return [SLError errorWithCode:SLErrorCodeBluetoothException failureReason:self.description];
}

@end
