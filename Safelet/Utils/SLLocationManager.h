//
//  LocationManager.h
//  Safelet
//
//  Created by Alex Motoc on 23/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;

/**
 *	Manager that gets the current location an uploads it to the current user's Parse entry every 10 minutes.
 *  Uploads the GeoPoint and the location name as well. If the location name is not available, uploads "unavailable" instead
 *  Works when the app is in background as well
 *
 *  THIS MANAGER SHOULD BE STARTED ONLY WHEN THE CURRENT USER IS SUCCESSFULLY LOGGED IN; OTHERWISE, THE PARSE UPLOAD OF THE LOCATION WILL FAIL
 */
@interface SLLocationManager : NSObject

// YES if AlarmMode is enabled; NO otherwise
@property (nonatomic) BOOL isPreciseLocationMode;

// YES if the manager is working; NO otherwise
@property (nonatomic) BOOL isActive;

// After the manager is started, this will store the last location found 
@property (strong, nonatomic) CLLocation *currentLocation;

NS_ASSUME_NONNULL_BEGIN
+ (instancetype)sharedManager; // constructor; just return a singleton

/**
 *  Retrieves and uploads to Parse the current location with a frequency of 5 seconds (i.e. every 5 seconds)
 *  Asks the user for permission to ALWAYS use the location.
 */
- (void)setupPreciseLocationTracking;

/**
 *	Starts the normal monitoring process, which detects significant location changes
 *  Asks the user for permission to ALWAYS use the location.
 */
- (void)setupNormalLocationTracking;

/**
 *	Stops the monitoring process by invalidating the timer and setting all strong references to helper objects to nil
 */
- (void)stopMonitoringLocation;

/**
 *	Returns the string to be used when location name is not available
 *
 *	@return NSString
 */
+ (NSString *)getUnavailableLocationDefaultName;
NS_ASSUME_NONNULL_END

/**
 *	Reverse geocodes the address from a given location using CLLGeocoder.
 *
 *	@param location		CLLocation for which we want the address
 *	@param completion	the completion block; - if success, "success" will be YES, and addressName can be either the actual address name, or a default string
 *                                              (kUnavailableLocationDefaultString) meaning that the geocoder couldn't find any address name for this location
 *                                            - if error, "success" will be NO, and "addreessName" will be nil
 */
+ (void)getAddressFromLocation:(CLLocation * _Nonnull)location
                    completion:(void (^ _Nullable)(BOOL success,
                                                   NSString * _Nullable addressName))completion;

@end
