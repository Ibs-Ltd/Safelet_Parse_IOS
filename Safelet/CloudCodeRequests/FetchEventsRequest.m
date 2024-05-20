//
//  FetchEventsRequest.m
//  Safelet
//
//  Created by Alex Motoc on 29/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "FetchEventsRequest.h"

@interface FetchEventsRequest ()
@property (strong, nonatomic) NSString *userObjectId;
@property (nonatomic) BOOL includeHistoric;
@end

@implementation FetchEventsRequest

+ (instancetype)requestWithUserObjectId:(NSString *)objectId
                  includeHistoricEvents:(BOOL)includeHistoric {
    FetchEventsRequest *request = [self request];
    
    request.userObjectId = objectId;
    request.includeHistoric = includeHistoric;
    
    return request;
}

- (NSString *)requestURL {
    return @"fetchNotificationsForUser";
}

- (NSDictionary *)params  {
    return @{@"aUserObjectId":self.userObjectId,
             @"includeHistoricEvents":@(self.includeHistoric)};
}

- (EventsList *)handleResponseData:(NSDictionary *)data {
    return [EventsList createFromDictionary:data];
}

@end
