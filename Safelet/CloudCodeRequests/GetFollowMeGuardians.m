//
//  GetFollowMeGuardians.m
//  Safelet
//
//  Created by Ram on 02/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "GetFollowMeGuardians.h"
#import <Parse/PFGeoPoint.h>

@interface GetFollowMeGuardians ()
@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) NSString *followMeObjectId;
@property (strong, nonatomic) PFGeoPoint *geoPoint;
@property (strong, nonatomic) NSString *locationName;
@end

@implementation GetFollowMeGuardians

+ (instancetype)GetFollowMeGuardians:(NSString *)objectId
                    followMeObjectId:(NSString *)followMeObjectId
                     checkInLocation:(PFGeoPoint *)geoPoint
                      checkInAddress:(NSString *)locationName{
    
    GetFollowMeGuardians *request = [self request];
    
    request.userObjectId = objectId;
    request.followMeObjectId = followMeObjectId;
    request.locationName = locationName;
    request.geoPoint = geoPoint;
    
    return request;
}

- (NSString *)requestURL {
    return @"getFollowMeGuardians";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"aObjectId":self.followMeObjectId,
             @"checkInGeoPoint":self.geoPoint,
             @"checkInAddress":self.locationName
             };
}
@end
