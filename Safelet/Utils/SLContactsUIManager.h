//
//  UserRelationsStringsManager.h
//  Safelet
//
//  Created by Alex Motoc on 15/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

typedef NS_ENUM(NSInteger, SLMessagePerspective) {
    SLMessagePerspectiveCurrentUser,
    SLMessagePerspectiveOtherUser
};

typedef NS_ENUM(NSInteger, SLGuardianStatus) {
    SLGuardianStatusMyGuardian,
    SLGuardianStatusGuarding
};

@class UserToUserInvitationStatus;
@class PhoneContact;
@class User;

/**
 *	A manager to show the appropriate strings for the relations between the current user and other users,
 *  and also get the appropriate actions when selecting a user from the contacts list.
 */
@interface SLContactsUIManager : NSObject
NS_ASSUME_NONNULL_BEGIN
/**
 *    Shared manager - use this class to show the SMS and email invitation screens
 *
 *    @return shared manager
 */
+ (instancetype)sharedManager;

- (void)showSMSInvitationScreenForPhoneNumbers:(NSArray<NSString *> *)phoneNumbers
                                   contactName:(NSString *)contactName
                      presentingViewController:(UIViewController *)viewController
                                    completion:(void(^ _Nullable)(BOOL success))completion;

#pragma mark - Parse contacts

/**
 *	Get the array of available actions for a guardian/guarded user from the MyConnections section.
 *
 *	@param otherUser		User object for which we are retrieving the available actions
 *	@param status			SLGuardianStatus representing whether the other user is this user's guardian,
                            or this user guards otherUser
 *	@param presentingVC     UIViewController used in some actions handlers (push/pop other view controllers, depending on what action was triggered)
 *	@param completion		the block to be executed in 'Remove guardian/Stop guarding' action handler
 *
 *	@return array of available UIAlertActions for the provided 'otherUser'
 */
+ (NSArray <UIAlertAction *> * _Nullable)getActionSheetActionsForOtherUser:(User * _Nonnull)otherUser
                                                            guardianStatus:(SLGuardianStatus)status
                                                  presentingViewController:(UIViewController * _Nullable)presentingVC
                                                removeConnectionCompletion:(void (^ _Nullable)(BOOL success,
                                                                                               NSError * _Nullable error))completion;

NS_ASSUME_NONNULL_END
@end
