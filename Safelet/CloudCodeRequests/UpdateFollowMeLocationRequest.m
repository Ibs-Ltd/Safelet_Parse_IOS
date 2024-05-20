//
//  UpdateFollowMeLocationRequest.m
//  Safelet
//
//  Created by Ram on 02/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "UpdateFollowMeLocationRequest.h"
#import <Parse/PFGeoPoint.h>

@interface UpdateFollowMeLocationRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) NSString *followMeObjectId;
@property (strong, nonatomic) PFGeoPoint *geoPoint;
@property (strong, nonatomic) NSString *locationName;
@end

@implementation UpdateFollowMeLocationRequest

+ (instancetype)updateFollowMeLocation:(NSString * _Nonnull)objectId
                      followMeObjectId:(NSString * _Nonnull)followMeObjectId
                       checkInLocation:(PFGeoPoint * _Nonnull)geoPoint
                        checkInAddress:(NSString * _Nonnull)locationName{
    
    UpdateFollowMeLocationRequest *request = [self request];
    
    request.userObjectId = objectId;
    request.followMeObjectId = followMeObjectId;
    request.locationName = locationName;
    request.geoPoint = geoPoint;
    
    return request;
}

- (NSString *)requestURL {
    return @"updateFollowMeLocation";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"aObjectId":self.followMeObjectId,
             @"checkInGeoPoint":self.geoPoint,
             @"checkInAddress":self.locationName
             };
}

@end
