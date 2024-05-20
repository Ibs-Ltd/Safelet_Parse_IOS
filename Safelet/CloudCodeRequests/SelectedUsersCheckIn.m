//
//  SelectedUsersCheckIn.m
//  Safelet
//
//  Created by Ram on 08/02/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "SelectedUsersCheckIn.h"
#import <Parse/PFGeoPoint.h>

@interface SelectedUsersCheckIn ()
@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) PFGeoPoint *geoPoint;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSArray *selectedUsers;
@end

@implementation SelectedUsersCheckIn
+ (instancetype)requestWithUserObjectIdMultiple:(NSString *)objectId
                        checkInLocation:(PFGeoPoint *)geoPoint
                         checkInAddress:(NSString *)locationName
                         checkInMessage:(NSString *)message
                        selectedUsers:(NSArray *)selectedUsers{
    
    SelectedUsersCheckIn *request = [self request];
    
    request.userObjectId = objectId;
    request.locationName = locationName;
    request.geoPoint = geoPoint;
    request.message = message;
    request.selectedUsers = selectedUsers;
    
    return request;
}

- (NSString *)requestURL {
    return @"createCheckInForMulitipleUser";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"checkInGeoPoint":self.geoPoint,
             @"checkInAddress":self.locationName,
             @"checkInMessage":self.message,
             @"selectedUsersObjectIds":self.selectedUsers
             };
}

@end
