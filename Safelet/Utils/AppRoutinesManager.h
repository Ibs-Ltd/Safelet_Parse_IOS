//
//  AppRoutinesManager.h
//  Safelet
//
//  Created by Alex Motoc on 23/05/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

/**
 Class used to handle all the app's routines like: location tracking, phone contacts managing, etc
 */
@interface AppRoutinesManager : NSObject

/**
 Runs the routines necessary for the app to work properly 
 */
+ (void)startSafeletRoutinesForUser:(User *)user;
+ (void)startSafeletRoutinesWithoutUser;
+ (void)startRoutinesForAppEnteredBackground;
+ (void)startRoutinesForAppEnteredForeground;

@end
