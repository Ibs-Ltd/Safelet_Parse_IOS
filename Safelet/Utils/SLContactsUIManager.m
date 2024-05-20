//
//  UserRelationsStringsManager.m
//  Safelet
//
//  Created by Alex Motoc on 15/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "SLContactsUIManager.h"
#import "UserToUserInvitationStatus.h"
#import "GuardianInvitationStatus.h"
#import "User.h"
#import "User+Requests.h"
#import "GuardianInvitation.h"
#import "Utils.h"
#import "CheckInViewController.h"
#import "SLErrorHandlingController.h"
#import "SendNonUserSMSInvitation.h"
#import "SLNotificationCenterNotifications.h"
#import "SLDataManager.h"
#import "PhoneContact.h"
#import <MessageUI/MessageUI.h>

typedef NS_ENUM(NSInteger, SLActionCompletionBlockType) {
    SLActionCompletionBlockTypeUserCancelledInvitation, // user selected cancel
    SLActionCompletionBlockTypeUserInvitedGuardian, // user selected invite
    SLActionCompletionBlockTypeUserRemovedGuardian, // user selected remove guard
    SLActionCompletionBlockTypeUserAcceptedInvitation, // user selected accept invitation
    SLActionCompletionBlockTypeUserRejectedInvitation, // user selected reject invitation
    SLActionCompletionBlockTypeUserStoppedGuarding // user selected stop guarding
};

typedef void(^ActionCompletionBlock)(BOOL, NSError *);

@interface SLContactsUIManager () <MFMessageComposeViewControllerDelegate>
@property (copy, nonatomic) void(^messageComposeCompletion)(BOOL success);
@end

@implementation SLContactsUIManager

+ (instancetype)sharedManager {
    static SLContactsUIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    
    return manager;
}

#pragma mark - Parse contacts

+ (NSArray<UIAlertAction *> *)getActionSheetActionsForOtherUser:(User *)otherUser
                                                 guardianStatus:(SLGuardianStatus)status
                                       presentingViewController:(UIViewController * _Nullable)presentingVC
                                     removeConnectionCompletion:(void (^ _Nullable)(BOOL, NSError * _Nullable))completion {
    NSMutableArray <UIAlertAction *> *actions = [NSMutableArray array];
    
    // see check-in action
    UIAlertAction *checkInAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"See last check-in", @"Action sheet option for connections")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              [otherUser fetchLastCheckinWithCompletion:^(CheckIn * _Nullable checkIn, NSError * _Nullable error) {
                                                                  if (error) {
                                                                      [SLErrorHandlingController handleError:error];
                                                                  } else if (!checkIn) {
                                                                      NSString *msg = NSLocalizedString(@"This user never performed a check-in", nil);
                                                                      [UIAlertController showAlertWithMessage:msg];
                                                                  } else {
                                                                      CheckInViewController *vc = [CheckInViewController createForUserCheckIn:checkIn];
                                                                      [presentingVC.navigationController pushViewController:vc animated:YES];
                                                                  }
                                                              }];
                                                          }];
    [actions addObject:checkInAction];
    
    // remove connection action
    NSString *removeConnectionMessage = nil;
    NSString *otherUserObjId = nil;
    User *senderUser = nil;
    if (status == SLGuardianStatusGuarding) {
        senderUser = otherUser;
        otherUserObjId = [User currentUser].objectId;
        
        removeConnectionMessage = NSLocalizedString(@"Stop guarding", @"Action sheet option for connections");
    } else if (status == SLGuardianStatusMyGuardian) {
        senderUser = [User currentUser];
        otherUserObjId = otherUser.objectId;
        
        removeConnectionMessage = NSLocalizedString(@"Remove guardian", @"Action sheet option for connections");
    } else {
        NSAssert(NO, @"ERROR: Provided guardian status is invalid");
    }
    
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:removeConnectionMessage
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:presentingVC.view animated:YES];
        
                                                             [senderUser removeGuardian:otherUserObjId
                                                                             completion:^(BOOL success, NSError * _Nullable error) {
                                                                 [hud hideAnimated:true];
                                                                                 if (completion) {
                                                                                     completion(success, error);
                                                                                 }
                                                                             }];
                                                         }];
    [actions addObject:removeAction];
    
    // add action to close action sheet
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [actions addObject:action];
    
    // return nil instead of only the Cancel option, meaning there are no actions for the selected user
    if (actions.count == 1) {
        return nil;
    }
    
    return actions;
}

#pragma mark - Phone contacts

/**
 *	Shows the SMS composition screen preloaded with an invitation message to join safelet
 *
 *	@param phoneNumbers		the phone numbers of a user, to which this SMS should be sent
 *	@param viewController	the view controller presenting the SMS composition view controller
 */

- (void)showSMSInvitationScreenForPhoneNumbers:(NSArray<NSString *> *)phoneNumbers
                                   contactName:(nonnull NSString *)contactName
                      presentingViewController:(UIViewController *)viewController
                                    completion:(void (^ _Nullable)(BOOL))completion {
    if (![MFMessageComposeViewController canSendText]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Your device isn't configured to send SMS!", nil)];
        return;
    }
    
    self.messageComposeCompletion = completion;
    
    NSString *format = NSLocalizedString(@"invitation_text_message %@ %@",@"Safelet invitation message");
    
    User *senderUser = [User currentUser];
    NSString *currentUsername = senderUser.name;
    
    NSString *text = [NSString stringWithFormat:format, contactName,currentUsername];
    
    MFMessageComposeViewController *messageController = [MFMessageComposeViewController new];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:phoneNumbers];
    [messageController setBody:text];
    messageController.navigationBar.tintColor = [UIColor whiteColor];
    [viewController presentViewController:messageController
                                 animated:YES
                               completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result {
    if (result == MessageComposeResultFailed) {
        self.messageComposeCompletion == nil ?: self.messageComposeCompletion(NO);
        self.messageComposeCompletion = nil;
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"An error occurred while sending the SMS. Please try again", nil)];
    } else if (result == MessageComposeResultSent) { // if the message was sent
        [controller dismissViewControllerAnimated:YES completion:^{
            // create a NonUserInvitation
            SendNonUserSMSInvitation *request = [SendNonUserSMSInvitation requestWithSenderObjectId:[User currentUser].objectId
                                                                                receiverPhoneNumber:controller.recipients[0]];
            [request setRequestCompletionBlock:^(id _Nullable response, NSError * _Nullable error) {
                if (error) {
                    NSString *msg = NSLocalizedString(@"Successfully invited user to join Safelet, but failed to invite as guardian because: ", nil);
                    msg = [msg stringByAppendingString:error.localizedDescription];
                    self.messageComposeCompletion == nil ?: self.messageComposeCompletion(NO);
                    self.messageComposeCompletion = nil;
                    [UIAlertController showErrorAlertWithMessage:msg];
                    return;
                }
                NSString *message = NSLocalizedString(@"Successfully invited user to be your guardian and to join Safelet", nil);
                [UIAlertController showSuccessAlertWithMessage:message];
                self.messageComposeCompletion == nil ?: self.messageComposeCompletion(YES);
                self.messageComposeCompletion = nil;
            }];
            
            [request runRequest];
        }];
    } else {
        [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
