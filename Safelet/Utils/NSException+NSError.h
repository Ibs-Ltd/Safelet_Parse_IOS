//
//  NSException+NSError.h
//  Safelet
//
//  Created by Alexandru Motoc on 13/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSException (NSError)

- (NSError *)toError;

@end
