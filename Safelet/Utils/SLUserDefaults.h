//
//  SLUserDefaults.h
//  Safelet
//
//  Created by Alex Motoc on 26/01/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLUserDefaults : NSObject

NS_ASSUME_NONNULL_BEGIN

/**
 *	Returns the last email address that was successfully logged into the app
 *
 *	@return NSString *
 */
+ (NSString *)previouslyUsedEmail;
+ (void)setPreviouslyUsedEmail:(NSString *)email;

NS_ASSUME_NONNULL_END

@end
