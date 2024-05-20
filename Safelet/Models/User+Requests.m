//
//  User+Requests.m
//  Safelet
//
//  Created by Alex Motoc on 06/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "User+Requests.h"
#import "CheckIfUserExistsRequest.h"
#import "SendGuardianInvitationRequest.h"
#import "RemoveGuardianRequest.h"
#import "RespondToGuardianInvitationRequest.h"
#import "CancelGuardianInvitationRequest.h"
#import "FetchListOfGuardianUsersRequest.h"
#import "FetchListOfGuardedUsersRequest.h"
#import "FetchLastCheckInForUserRequest.h"
#import "CreateCheckInRequest.h"
#import "DispatchAlarmRequest.h"
#import "FetchEventsRequest.h"
#import "FetchActiveAlarmRequest.h"
#import "JoinAlarmRequest.h"
#import "IgnoreAlarmRequest.h"
#import "Alarm.h"
#import "GuardianInvitation.h"
#import "CancelNonUserSMSInvitation.h"
#import "SLErrorHandlingController.h"
#import "SelectedUsersCheckIn.h"
#import "StartFollowMeRequest.h"
#import "UpdateFollowMeLocationRequest.h"
#import "GetFollowMeGuardians.h"
#import "StopFollowMeRequest.h"
#import "StopFollowUserRequest.h"
#import "GetFollowUserLocationRequest.h"
#import "checkCurrentFollowRequest.h"

static BOOL isDispatchingAlarm = NO;

@implementation User (Requests)

- (void)checkIfUserExistsWithCompletion:(void (^)(BOOL, NSError * _Nullable))completion {
    CheckIfUserExistsRequest *request = [CheckIfUserExistsRequest requestWithUsername:self.username];
    [request setRequestCompletionBlock:^(NSNumber * _Nullable exists, NSError * _Nullable error) {
        BOOL userExists = [exists boolValue];
        
        if (error && [[SLErrorHandlingController getServerErrorPayloadDictionaryFromError:error][@"localizedKey"] isEqualToString:@"CHECK_USER_NOT_FOUND_ERROR"]) {
            userExists = NO;
            
            error = nil;
        }
        
        if (completion) {
            completion(userExists, error);
        }
    }];
    
    [request runRequest];
}

#pragma mark - Guardian invitation actions

- (void)cancelSMSInvitation:(NSString *)phoneNumber completion:(RequestBooleanCompletionBlock)completion {
    CancelNonUserSMSInvitation *cancel = [CancelNonUserSMSInvitation requestWithPhoneNumber:phoneNumber];
    [cancel setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        completion == nil ?: completion([response boolValue], error);
    }];
    [cancel runRequest];
}

- (void)inviteUserAsGuardian:(NSString *)userObjectId
                  completion:(RequestBooleanCompletionBlock _Nullable)completion {
    SendGuardianInvitationRequest *request = [SendGuardianInvitationRequest requestWithFromUserObjectId:self.objectId
                                                                                         toUserObjectId:userObjectId];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}

- (void)removeGuardian:(NSString *)userObjectId
            completion:(RequestBooleanCompletionBlock _Nullable)completion {
    NSString *initiator = [User currentUser].objectId; // all actions are initiated by the current user
    
    RemoveGuardianRequest *request = [RemoveGuardianRequest requestWithFromUserObjectId:self.objectId
                                                                         toUserObjectId:userObjectId
                                                                  initiatorUserObjectId:initiator];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}

- (void)respondToGuardianInvitationFromUser:(NSString *)userObjectId
                               responseType:(SLGuardianInvitationResponseType)responseType
                                 completion:(RequestBooleanCompletionBlock _Nullable)completion {
    
    RespondToGuardianInvitationRequest *request = [RespondToGuardianInvitationRequest requestWithFromUserObjectId:userObjectId
                                                                                                   toUserObjectId:self.objectId
                                                                                                   responseStatus:responseType];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}

- (void)cancelGuardianInvitationSentToUser:(NSString *)userObjectId
                                completion:(RequestBooleanCompletionBlock _Nullable)completion {
    CancelGuardianInvitationRequest *request = [CancelGuardianInvitationRequest requestWithFromUserObjectId:self.objectId
                                                                                             toUserObjectId:userObjectId];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}

#pragma mark - List of Guardians and Guarded

- (void)fetchListOfGuardiansWithCompletion:(void (^)(NSArray<User *> * _Nullable, NSError * _Nullable))completion {
    FetchListOfGuardianUsersRequest *request = [FetchListOfGuardianUsersRequest requestWithUserObjectId:self.objectId];
    request.showsProgressIndicator = NO;
    request.runsInBackground = NO;
    
    [request setRequestCompletionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}

- (void)fetchListOfGuardedWithCompletion:(void (^)(NSArray<User *> * _Nullable, NSError * _Nullable))completion {
    FetchListOfGuardedUsersRequest *request = [FetchListOfGuardedUsersRequest requestWithUserObjectId:self.objectId];
    request.showsProgressIndicator = NO;
    request.runsInBackground = NO;
    
    [request setRequestCompletionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}

#pragma mark - CheckIn

- (void)fetchLastCheckinWithCompletion:(void (^)(CheckIn * _Nullable, NSError * _Nullable))completion {
    FetchLastCheckInForUserRequest *request = [FetchLastCheckInForUserRequest requestWithUserObjectId:self.objectId];
    
    [request setRequestCompletionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}

- (void)sendCheckInWithGeoPoint:(PFGeoPoint *)geoPoint
                        address:(NSString *)address
                        message:(NSString *)message
                     completion:(RequestBooleanCompletionBlock _Nullable)completion {
    CreateCheckInRequest *request = [CreateCheckInRequest requestWithUserObjectId:self.objectId
                                                              checkInLocation:geoPoint
                                                               checkInAddress:address
                                                               checkInMessage:message];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}

- (void)sendCheckInWithGeoPointMultiple:(PFGeoPoint *)geoPoint address:(NSString *)address message:(NSString *)message selectedUsers:(NSArray *)selectedUsers completion:(RequestBooleanCompletionBlock)completion{
    
    SelectedUsersCheckIn *request = [SelectedUsersCheckIn requestWithUserObjectIdMultiple:self.objectId
                                                                          checkInLocation:geoPoint
                                                                           checkInAddress:address
                                                                           checkInMessage:message
                                                                            selectedUsers:selectedUsers];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}
#pragma mark - Follow me
-(void)startFollowMeToGuardians:(PFGeoPoint *)geoPoint address:(NSString *)address selectedUsers:(NSArray *)selectedUsers completion:(void (^ _Nullable)(NSString * _Nullable objectId,                                                                                                                                                       NSError * _Nullable error))completion{

    StartFollowMeRequest *request = [StartFollowMeRequest startFollowMeToGuardians:self.objectId checkInLocation:geoPoint checkInAddress:address selectedUsers:selectedUsers];
    
    [request setRequestCompletionBlock:^(NSString *_Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}
-(void)updateFollowMeLocation:(PFGeoPoint *)geoPoint address:(NSString *)address aObjectId:(NSString *)aObjectId completion:(RequestBooleanCompletionBlock)completion{
    
    UpdateFollowMeLocationRequest *request = [UpdateFollowMeLocationRequest updateFollowMeLocation:self.objectId followMeObjectId:aObjectId checkInLocation:geoPoint checkInAddress:address];
    
    [request setRequestCompletionBlock:^(NSNumber *_Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}
-(void)getFollowMeGuardians:(PFGeoPoint *)geoPoint address:(NSString *)address aObjectId:(NSString *)aObjectId completion:(void (^)(NSArray * _Nullable, NSError * _Nullable))completion{
    
    GetFollowMeGuardians *request = [GetFollowMeGuardians GetFollowMeGuardians:self.objectId followMeObjectId:aObjectId checkInLocation:geoPoint checkInAddress:address];
    
    [request setRequestCompletionBlock:^(NSArray *_Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}
-(void)stopFollowMe:(NSString *)aObjectId completion:(RequestBooleanCompletionBlock)completion{
    
    StopFollowMeRequest *request = [StopFollowMeRequest stopFollowMe:self.objectId followMeObjectId:aObjectId];
    
    [request setRequestCompletionBlock:^(NSNumber *_Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}
-(void)stopFollowUser:(NSString *)aObjectId completion:(RequestBooleanCompletionBlock)completion{
    
    StopFollowUserRequest *request = [StopFollowUserRequest stopFollowUser:self.objectId followMeObjectId:aObjectId];
    
    [request setRequestCompletionBlock:^(NSNumber *_Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}
-(void)getFollowUserLocation:(NSString *)aObjectId completion:(void (^)(NSArray * _Nullable, NSError * _Nullable))completion{
    
    GetFollowUserLocationRequest *request = [GetFollowUserLocationRequest getFollowUserLocation:self.objectId followMeObjectId:aObjectId];
    
    [request setRequestCompletionBlock:^(NSArray *_Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}
-(void)checkCurrentFollow:(void (^)(NSArray * _Nullable, NSError * _Nullable))completion{
    
    checkCurrentFollowRequest *request = [checkCurrentFollowRequest checkCurrentFollow:self.objectId];
    
    [request setRequestCompletionBlock:^(NSArray *_Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}
#pragma mark - Alarm

- (void)dispatchAlarmWithCompletion:(void (^ _Nullable)(Alarm * _Nullable alarm,
                                                        NSError * _Nullable error))completion {
    if (isDispatchingAlarm) {
        return;
    }
    
    isDispatchingAlarm = YES;
    DispatchAlarmRequest *request = [DispatchAlarmRequest requestWithUserObjectId:self.objectId];
    
    [request setRequestCompletionBlock:^(Alarm * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
        isDispatchingAlarm = NO;
    }];
    
    [request runRequest];
}

- (void)fetchActiveAlarmWithCompletion:(void (^ _Nullable)(Alarm * _Nullable alarm,
                                                           NSError * _Nullable error))completion {
    FetchActiveAlarmRequest *request = [FetchActiveAlarmRequest requestWithUserObjectId:self.objectId];
    
    request.showsProgressIndicator = NO;
    
    [request setRequestCompletionBlock:^(Alarm * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, error);
        }
    }];
    
    [request runRequest];
}

- (void)joinAlarmWithObjectId:(NSString *)alarmObjId
                   completion:(RequestBooleanCompletionBlock)completion {
    JoinAlarmRequest *request = [JoinAlarmRequest requestWithUserObjectId:self.objectId
                                                            alarmObjectId:alarmObjId];
    
    [request setRequestCompletionBlock:^(NSNumber * _Nullable response,
                                         NSError * _Nullable error) {
        if (completion) {
            completion([response boolValue], error);
        }
    }];
    
    [request runRequest];
}

- (void)ignoreAlarmWithObjectId:(NSString *)alarmObjId completion:(RequestBooleanCompletionBlock)completion {
    IgnoreAlarmRequest *request = [IgnoreAlarmRequest requestWithAlarmObjectId:alarmObjId];
    
    [request setRequestCompletionBlock:^(id  _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response != nil, error); // if response != nil we have success
        }
    }];
    
    [request runRequest];
}

#pragma mark - Events

- (void)fetchEvents:(BOOL)includeHistoric withProgressIndicator:(BOOL)showProgressIndicator
         completion:(void (^)(EventsList * _Nullable, NSUInteger, NSError * _Nullable))completion {
    FetchEventsRequest *request = [FetchEventsRequest requestWithUserObjectId:self.objectId includeHistoricEvents:includeHistoric];
    
    request.showsProgressIndicator = showProgressIndicator;
    [request setRequestCompletionBlock:^(EventsList * _Nullable response, NSError * _Nullable error) {
        if (completion) {
            completion(response, response.importantEventsCount, error);
        }
    }];
    
    [request runRequest];
}

#pragma mark - Guardian Network

- (void)setUserIsCommunityGuardian:(BOOL)isCommunityGuardian
                        completion:(void(^)(BOOL success, NSError * _Nullable error))completion {
    self.isCommunityMember = isCommunityGuardian;
    
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (completion) {
            completion(succeeded, error);
        }
    }];
}

@end
