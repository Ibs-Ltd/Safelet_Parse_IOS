//
//  StartFollowMeRequest.m
//  Safelet
//
//  Created by Ram on 01/05/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "StartFollowMeRequest.h"
#import <Parse/PFGeoPoint.h>

@interface StartFollowMeRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) PFGeoPoint *geoPoint;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSArray *selectedUsers;
@end

@implementation StartFollowMeRequest

+ (instancetype)startFollowMeToGuardians:(NSString *)objectId
                         checkInLocation:(PFGeoPoint *)geoPoint
                          checkInAddress:(NSString *)locationName
                           selectedUsers:(NSArray *)selectedUsers{
    
    StartFollowMeRequest *request = [self request];
    
    request.userObjectId = objectId;
    request.locationName = locationName;
    request.geoPoint = geoPoint;
    request.selectedUsers = selectedUsers;
    
    return request;
}

- (NSString *)requestURL {
    return @"startFollowMeToMulitipleGuardians";//
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"checkInGeoPoint":self.geoPoint,
             @"checkInAddress":self.locationName,             
             @"selectedUsersObjectIds":self.selectedUsers
             };
}

@end
