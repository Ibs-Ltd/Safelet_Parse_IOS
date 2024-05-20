//
//  SLDataManager.h
//  Safelet
//
//  Created by Alex Motoc on 03/12/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EventsList.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * kImportantEventsCountKeyPath = @"importantEventsCount";
static NSString * kFollowMeObjectIdKeyPath = @"followMeObjectId";
static NSString * kFollowUserObjectIdKeyPath = @"followUserObjectId";

@class User, Alarm, UserToUserInvitationStatus, GuardianInvitation, CheckIn, PhoneContact,FollowMe;
@interface SLDataManager : NSObject

@property (nonatomic, readonly) NSInteger importantEventsCount; // different from events.count, because we are only interested in alarms and invitations
// events array; has objects in this SPECIFIC order: Alarm, GuardianInvitation, CheckIn
@property (strong, nonatomic, readonly, nullable) EventsList *events;
@property (strong, nonatomic, readonly, nullable) NSArray <User *> *guardianUsers;
@property (strong, nonatomic, readonly, nullable) NSArray <User *> *guardedUsers;
@property (strong, nonatomic, readonly, nullable) NSArray <PhoneContact *> *phoneContactsMatched; // list of phone contacts matched with the Parse users
@property (strong, nonatomic, readonly, nullable) NSDictionary <NSString *, NSString *> *phoneContactsSimple; // phone number mapped to the contact name

// YES if the My Connections screen data has been loaded (guardian and guarded users)
@property (nonatomic, readonly) BOOL didLoadMyConnections;
@property (nonatomic) BOOL includeHistoricEvents;

@property (nonatomic) NSInteger presentedLowBatteryNotificationsCount;

+ (instancetype)sharedManager;

/**
 *	Resets data
 */
- (void)clearCachedData;

#pragma mark - MyConnections data handling

- (void)fetchConnectionsWithCompletion:(void(^)(NSArray *guardians, NSArray *guarded, NSError *error))completion;
- (void)handleNewConnection:(User *)user isGuardian:(BOOL)isGuardian;
- (void)removeConnection:(User *)user isGuardian:(BOOL)isGuardian;

#pragma mark - Contacts
- (void)fetchPhoneContactsWithCompletion:(void(^)(NSArray <PhoneContact *> *phoneContacts,
                                                  NSError *error))completion;
- (void)syncContactsListWithCompletion:(void (^ _Nullable)(NSError * _Nullable error))completion;

#pragma mark - Events data handling

// this automatically takes into consideration the value for "includeHistoricEvents"
// therefore, make sure you set this to whatever value you need before calling this method
- (void)fetchEventsWithProgressIndicator:(BOOL)showProgressIndicator
                              completion:(void (^ _Nullable)(EventsList * _Nullable events,
                                                             NSUInteger importantEventsCount,
                                                             NSError * _Nullable error))completion;

- (void)handleStopAlarm:(Alarm *)alarm;

#pragma mark - Guardian Network handling

- (void)setUserIsCommunityGuardian:(BOOL)isCommunityGuard
                        completion:(void(^)(BOOL success, NSError *error))completion;

#pragma mark - Push Notification objects handling

- (void)handlePushNotificationInvitation:(GuardianInvitation *)invitation;
- (void)handlePushNotificationAlarm:(Alarm *)alarm joinUserName:(NSString *)name; // user name of user who joined
- (void)handlePushNotificationCheckIn:(CheckIn *)checkIn;
- (void)handlePushNotificationFollowMe:(FollowMe *)followMe;
- (void)handlePushNotificationUserPolicy:(User *)user;

NS_ASSUME_NONNULL_END

@end
