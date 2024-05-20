//
//  User+Requests.h
//  Safelet
//
//  Created by Alex Motoc on 06/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "User.h"
#import "EventsList.h"
#import "UserToUserInvitationStatus.h"
#import "GuardianInvitationStatus.h"

typedef void(^RequestBooleanCompletionBlock)(BOOL success, NSError * _Nullable error);
typedef void(^RequestStringCompletionBlock)(NSString *_Nullable success, NSError * _Nullable error);

@class GuardianInvitation;
@class CheckIn;
@class Alarm;
@interface User (Requests)

NS_ASSUME_NONNULL_BEGIN

/**
 *	Checks if a user with the same username already exists.
 *
 *	@param block	The block to execute. `exists` will be `YES` if an existent user has been found, otherwise it will be set to `NO`. Any errors will be found in  `error`
 */
- (void)checkIfUserExistsWithCompletion:(void (^ _Nonnull)(BOOL exists, NSError * _Nullable error))completion;

#pragma mark - Guardian Invitation

- (void)cancelSMSInvitation:(NSString * _Nonnull)phoneNumber completion:(RequestBooleanCompletionBlock _Nullable)completion;

/**
 *	Invite other Parse user to be this user's guardian
 *
 *	@param userObjectId     the destination User objectId
 *	@param completion		the completion block to be executed when the operation finished
 */
- (void)inviteUserAsGuardian:(NSString * _Nonnull)userObjectId
                  completion:(RequestBooleanCompletionBlock _Nullable)completion;

/**
 *	Remove other Parse user from being this user's guardian
 *
 *	@param userObjectId     the destination User objectId
 *	@param completion		the completion block to be executed when the operation finished
 */
- (void)removeGuardian:(NSString * _Nonnull)userObjectId
            completion:(RequestBooleanCompletionBlock _Nullable)completion;

/**
 *	Respond to an invitation recevied from another user.
 *  We don't need the invitation object, since there can only be one invitaion object having this user as source user and another user as destination.
 *
 *	@param userObjectId	the destination User objectId
 *	@param responseType		type of response (can be either ACCEPTED or REJECTED)
 *	@param completion		the completion block to be executed when the operation finished
 */
- (void)respondToGuardianInvitationFromUser:(NSString * _Nonnull)userObjectId
                               responseType:(SLGuardianInvitationResponseType)responseType
                                 completion:(RequestBooleanCompletionBlock _Nullable)completion;

/**
 *	Cancel an invitation sent to a Parse user to be this user's guardian.
 *  We don't need the invitation object, since there can only be one invitaion object having this user as source user and another user as destination.
 *
 *	@param userObjectId     the destination User objectId
 *	@param completion		the completion block to be executed when the operation finished
 */
- (void)cancelGuardianInvitationSentToUser:(NSString * _Nonnull)userObjectId
                                completion:(RequestBooleanCompletionBlock _Nullable)completion;

#pragma mark - List of Guardians

/**
 *	Get the list of guardians for this user
 *  By defaults showsProgressIndicator is hidden
 *
 *	@param completion	completion block to be executed
 */
- (void)fetchListOfGuardiansWithCompletion:(void (^ _Nullable)(NSArray <User *> * _Nullable response,
                                                               NSError * _Nullable error))completion;

/**
 *	Get the list of users this user is guarding
 *  By defaults showsProgressIndicator is hidden
 *
 *	@param completion	completion block to be executed
 */
- (void)fetchListOfGuardedWithCompletion:(void (^ _Nullable)(NSArray <User *> * _Nullable response,
                                                             NSError * _Nullable error))completion;

#pragma mark - CheckIn

/**
 *	Get the last check-in created by this user.
 *
 *	@param completion	block
 */
- (void)fetchLastCheckinWithCompletion:(void (^ _Nullable)(CheckIn * _Nullable checkIn,
                                                           NSError * _Nullable error))completion;

/**
 *	Runs the request to send a new check in
 *
 *	@param geoPoint	the geopoint of the check in location
 *	@param address	the location name (address)
 *	@param message	the user provided message
 */
- (void)sendCheckInWithGeoPoint:(PFGeoPoint * _Nonnull)geoPoint
                        address:(NSString * _Nonnull)address
                        message:(NSString * _Nullable)message
                     completion:(RequestBooleanCompletionBlock _Nullable)completion;


- (void)sendCheckInWithGeoPointMultiple:(PFGeoPoint * _Nonnull)geoPoint
                        address:(NSString * _Nonnull)address
                        message:(NSString * _Nullable)message
                          selectedUsers:(NSArray * _Nullable)selectedUsers
                     completion:(RequestBooleanCompletionBlock _Nullable)completion;


/**
 *    Runs the request to Start Follow Me
 *
 *    @param geoPoint    the geopoint of the check in location
 *    @param address    the location name (address)
 *    @param message    the user provided message
 */

- (void)startFollowMeToGuardians:(PFGeoPoint * _Nonnull)geoPoint
                                address:(NSString * _Nonnull)address                                
                          selectedUsers:(NSArray * _Nullable)selectedUsers
                      completion:(void (^ _Nullable)(NSString * _Nullable objectId,
                                                     NSError * _Nullable error))completion;

- (void)updateFollowMeLocation:(PFGeoPoint * _Nonnull)geoPoint
                       address:(NSString * _Nonnull)address
                     aObjectId:(NSString * _Nullable)aObjectId
                    completion:(RequestBooleanCompletionBlock _Nullable)completion;

- (void)getFollowMeGuardians:(PFGeoPoint * _Nonnull)geoPoint
                       address:(NSString * _Nonnull)address
                     aObjectId:(NSString * _Nullable)aObjectId
                  completion:(void (^ _Nullable)(NSArray * _Nullable guardians,
                                                 NSError * _Nullable error))completion;

- (void)stopFollowMe:(NSString * _Nullable)aObjectId
          completion:(RequestBooleanCompletionBlock _Nullable)completion;

- (void)stopFollowUser:(NSString * _Nullable)aObjectId
          completion:(RequestBooleanCompletionBlock _Nullable)completion;

- (void)getFollowUserLocation:(NSString * _Nullable)aObjectId                     
                  completion:(void (^ _Nullable)(NSArray * _Nullable followData,
                                                 NSError * _Nullable error))completion;

- (void)checkCurrentFollow:(void (^ _Nullable)(NSArray * _Nullable response,
                                                 NSError * _Nullable error))completion;

#pragma mark - Alarm

/**
 *	Creates an Alarm object associated to this user. 
 *  Push notifications will be sent to this user's guardians, notifying them that this user needs help
 *  Shows progress indicator: YES
 *
 *	@param completion   upon success, the alarm object will be returned, or the encountered error
 */
- (void)dispatchAlarmWithCompletion:(void (^ _Nullable)(Alarm * _Nullable alarm,
                                                        NSError * _Nullable error))completion;

/**
 *	Searches for the active alarm dispatched by this user if any.
 *  Shows progress indicator: NO
 *
 *	@param completion	return the active alarm dispatched by this user or nil if not found or if encountered error
 */
- (void)fetchActiveAlarmWithCompletion:(void (^ _Nullable)(Alarm * _Nullable alarm,
                                                           NSError * _Nullable error))completion;

/**
 *	Joins this user to an alarm object (adds it to the alarm's participants list)
 *
 *	@param alarmObjId	the objectId of the alarm this user is joining
 *	@param completion	standard boolean completion block
 */
- (void)joinAlarmWithObjectId:(NSString * _Nonnull)alarmObjId
                   completion:(RequestBooleanCompletionBlock _Nullable)completion;

/**
 *	Ignores this alarm object (adds the user to the alarm's ignoring list)
 *
 *	@param alarmObjId	the objectId of the alarm this user is ignoring
 *	@param completion	standard boolean completion block
 */
- (void)ignoreAlarmWithObjectId:(NSString * _Nonnull)alarmObjId
                     completion:(RequestBooleanCompletionBlock _Nullable)completion;

#pragma mark - Events

/**
 *	Fetches the list of events for this user. Events can be invitations sent to this user that are pending, 
 *  check-ins created by users guarded by this user, alarms that are dispatched by users that this user is guarding.
 *
 *  If this user is a community member, alarms disptached by users in a range of 1 kilometer are also retrieved as events.
 *
 *	@param completion	return - the list of events which can contain alarms, invitations and checkins
 *                             - the number of important events (i.e. alarms and invitations); to be used when showing the events badge
 *                             - or the encountered error
 *
 */
- (void)fetchEvents:(BOOL)includeHistoric withProgressIndicator:(BOOL)showProgressIndicator
         completion:(void (^ _Nullable)(EventsList * _Nullable events,
                                        NSUInteger importantEventsCount,
                                        NSError * _Nullable error))completion;

#pragma mark - Guardian Network

- (void)setUserIsCommunityGuardian:(BOOL)isCommunityGuardian
                        completion:(void(^)(BOOL success, NSError * _Nullable error))completion;

NS_ASSUME_NONNULL_END

@end
