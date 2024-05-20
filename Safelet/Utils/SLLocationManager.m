//
//  LocationManager.m
//  Safelet
//
//  Created by Alex Motoc on 23/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "SLLocationManager.h"
#import "User.h"
#import <AddressBookUI/AddressBookUI.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/PFGeoPoint.h>

/**
 *	Default string that is returned when getAddressFromLocation:completion: doesn't find any address for the given location
 */
static NSString * _Nonnull const kUnavailableLocationDefaultName = @"unavailable";
static NSTimeInterval const kAlertInterval = 5; // 5 sec (send location every 5 seconds when in alarm situation)

@interface SLLocationManager () <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) User *currentUser;
@property (strong, nonatomic) NSDate *lastValidTimestamp;
@end

@implementation SLLocationManager

+ (instancetype)sharedManager {
    static SLLocationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    
    return manager;
}

+ (NSString *)getUnavailableLocationDefaultName {
    return kUnavailableLocationDefaultName;
}

#pragma mark - Start/Stop location tracking

- (void)setupNormalLocationTracking {
    if (!self.currentUser) {
        self.currentUser = [User currentUser];
        
        if (!self.currentUser) { // current user is logged out
            return;
        }
    }
    
    self.isPreciseLocationMode = NO; // alarm mode is disabled
    
    [self.locationManager stopUpdatingLocation];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    [self.locationManager requestAlwaysAuthorization]; // This enables the location to be retrieved in the background
    
    self.currentLocation = self.locationManager.location;
}

- (void)setupPreciseLocationTracking {
    if (!self.currentUser) {
        self.currentUser = [User currentUser];
        
        if (!self.currentUser) { // current user is logged out
            return;
        }
    }
    
    self.isPreciseLocationMode = YES; // alarm mode is enabled
    
    [self.locationManager stopMonitoringSignificantLocationChanges];
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.activityType = CLActivityTypeFitness; // any pedestrian activity
    /**
     *  Movement threshold for new events.
     *	Location updates will occur only when there is a 10 meter difference from the new location and the last location update.
     */
    self.locationManager.distanceFilter = 10;
    [self.locationManager requestAlwaysAuthorization];
    
    self.currentLocation = self.locationManager.location;
}

- (void)stopMonitoringLocation {
    if (self.isPreciseLocationMode) { // if alarm mode, we must stop the standard location service
        [self.locationManager stopUpdatingLocation];
    } else { // otherwise, stop the significant changes services
        [self.locationManager stopMonitoringSignificantLocationChanges];
    }
    
    self.currentUser = nil;
    self.locationManager = nil;
    self.currentLocation = nil;
    self.isActive = NO;
}

#pragma mark - Location handling

/**
 *  Updates the currentLocation property
 *
 *    Handles a given CLLocation object. This means that it creates a PFGeoPoint for this location, assign it to the current user
 *  and saves the new user data to Parse. Also, it tries to find the location name from the provided coordinates; if successful
 *  assigns the location name to the current user locationName property, otherwise assigns "unavailable", and then saves to Parse.
 *
 *    @param location     CLLocation - A location object
 */
- (void)handleLocation:(CLLocation *)location {
    self.currentLocation = self.locationManager.location;
    
    if (!self.lastValidTimestamp) { // initialize the lastValidTimestamp with current timestamp if it's nil
        self.lastValidTimestamp = location.timestamp;
    }
    
    // seconds that passed since the last valid location update until now
    NSTimeInterval lastUpdate = fabs([self.lastValidTimestamp timeIntervalSinceNow]);
    // seconds that passed since the current location update until now
    NSTimeInterval currentUpdate = fabs([location.timestamp timeIntervalSinceNow]);
    
    /**
     *	Discussion: CLLocationManager might return a location from cache, therefore we must check if the "location" object that
     *  we received is usable and up to date, and not a location object older than one we already processed
     */
    if (currentUpdate - lastUpdate > 1) { // we check with precision of 1 second
        return;
    }
    
    /**
     *	Discussion: when the app is in Alarm Mode, we must send updates to Parse with a frequency of 5 seconds
     *  such that we don't force Parse's request limit.
     */
    if (self.isPreciseLocationMode && lastUpdate < kAlertInterval) {
        return; // discard any location updates that occur faster than the allowed Alarm updates interval
    }
    
    // save the last processed location time
    self.lastValidTimestamp = location.timestamp;
    
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLocation:location];
    self.currentUser.locationCoordinates = geoPoint;
    [self.currentUser saveInBackground];
    
    [self.class getAddressFromLocation:location
                            completion:^(BOOL success, NSString * _Nullable addressName) {
                                if (!success) { // address retrieval failed
                                    return;
                                }
                                
                                self.currentUser.locationName = addressName;
                                [self.currentUser saveInBackground];
                            }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
        if (self.locationManager.location) { // if a location was already received, handle it
            [self handleLocation:self.locationManager.location];
        }
        
        if (self.isPreciseLocationMode) { // if is alarm mode
            [self.locationManager startUpdatingLocation]; // start normal location tracking
        } else {
            [self.locationManager startMonitoringSignificantLocationChanges]; // or start monitoring significant location changes
        }
        
        self.isActive = YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self handleLocation:locations.lastObject];
}

#pragma mark - Utils

+ (void)getAddressFromLocation:(CLLocation *)location
                    completion:(void (^ _Nullable)(BOOL success,
                                                   NSString * _Nullable addressName))completion {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       if (error) {
                           // if geocoder didn't find any results, use default "unavailable" string
                           if (error.code == kCLErrorGeocodeFoundNoResult) {
                               completion(YES, kUnavailableLocationDefaultName);
                           } else { // if error occurred from any other reasons, geocoding failed
                               completion(NO, nil);
                           }
                       } else if (!placemarks || placemarks.count == 0) { // if no placemarks found, use default "unavailable" string
                           completion(YES, kUnavailableLocationDefaultName);
                       } else { // if reverse geocoding successful, return address string from address dictionary
                           CLPlacemark *placemark = placemarks.lastObject;
                           
                           NSArray *lines = placemark.addressDictionary[@"FormattedAddressLines"];
                           NSString *address = [lines componentsJoinedByString:@", "];
                           
                           completion(YES, address);
                       }
                   }];
}

@end
