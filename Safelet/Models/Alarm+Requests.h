//
//  Alarm+Requests.h
//  Safelet
//
//  Created by Alex Motoc on 03/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "Alarm.h"

@class AlarmRecordingChunk;
@interface Alarm (Requests)

/**
 *	Stops this alarm by setting its "isActive" property to false
 *  Shows progress indicator: YES
 *
 *	@param completion   return a boolean for success status and encountered error object
 */
- (void)stopWithReason:(StopReason)reason
     reasonDescription:(NSString * _Nullable)reasonDescription
            completion:(void(^ _Nullable)(BOOL success, NSError * _Nullable error))completion;

/**
 *	Checks if a given user is participating to this alarm
 *  Shows progress indicator: YES
 *
 *	@param user				the user to check
 *	@param completion       return YES/NO if the user is participating or not, or the encountered error
 */
- (void)checkIfUserIsParticipant:(User * _Nonnull)user
                      completion:(void(^ _Nullable)(BOOL isParticipant, NSError * _Nullable error))completion;

/**
 *	Fetches the list of Users that are participating to this alarm.
 *
 *	@param showProgress     bool to indicate whether to show a progress indicator or not
 *	@param completion       return the list of users that are participants, or the encountered error
 */
- (void)fetchParticipantsWithProgressIndicator:(BOOL)showProgress
                                    completion:(void(^ _Nullable)(NSArray <User *> * _Nullable participants,
                                                                  NSError * _Nullable error))completion;

/**
 *	Fetches if needed the alarm data and the dispatcher user pointer ("user" property)
 *  Shows progress indicator: NO 
 *
 *	@param completion	the encountered error if any
 */
- (void)refreshAlarmDataInBackgroundWithCompletion:(void(^ _Nullable)(Alarm * _Nullable alarm, NSError * _Nullable error))completion;


- (void)fetchRecordingChunksWithCompletion:(void (^ _Nullable)(NSArray<AlarmRecordingChunk *> * _Nullable chunks, NSError * _Nullable error))completion;

- (void)fetchLastRecordingChunkWithCompletion:(void (^ _Nullable)(AlarmRecordingChunk * _Nullable chunk, NSError * _Nullable error))completion;

- (void)notifyParticipantsCurrentUserCalledEmergency:(void (^ _Nonnull)(BOOL success, NSError * _Nullable error))completion;

@end
