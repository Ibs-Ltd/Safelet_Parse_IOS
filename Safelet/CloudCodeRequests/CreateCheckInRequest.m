//
//  SendCheckInRequest.m
//  Safelet
//
//  Created by Alex Motoc on 29/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CreateCheckInRequest.h"
#import <Parse/PFGeoPoint.h>

@interface CreateCheckInRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@property (strong, nonatomic) PFGeoPoint *geoPoint;
@property (strong, nonatomic) NSString *locationName;
@property (strong, nonatomic) NSString *message;
@end

@implementation CreateCheckInRequest

+ (instancetype)requestWithUserObjectId:(NSString *)objectId
                        checkInLocation:(PFGeoPoint *)geoPoint
                         checkInAddress:(NSString *)locationName
                         checkInMessage:(NSString *)message {
    CreateCheckInRequest *request = [self request];
    
    request.userObjectId = objectId;
    request.locationName = locationName;
    request.geoPoint = geoPoint;
    request.message = message;
    
    return request;
}

- (NSString *)requestURL {
    return @"createCheckInForUser";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"checkInGeoPoint":self.geoPoint,
             @"checkInAddress":self.locationName,
             @"checkInMessage":self.message};
}

@end
