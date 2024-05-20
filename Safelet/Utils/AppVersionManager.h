//
//  AppVersionManager.h
//  Safelet
//
//  Created by Alex Motoc on 25/07/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

// DISABLED FOR NOW

/**
 *  Use this to search for the latest live app version. This manager will show
 *  an alert in case the app is not the latest version. The user can select to
 *  update the app from the alert => the manager will display the app in the App Store
 */
@interface AppVersionManager : NSObject

+ (instancetype)sharedManager;
- (void)checkForLatestAppVersion;

@end
