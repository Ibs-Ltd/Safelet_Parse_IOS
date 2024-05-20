//
//  SLPushNotificationManager.m
//  Safelet
//
//  Created by Alex Motoc on 18/12/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "SLPushNotificationManager.h"
#import "PushNotification.h"
#import "Utils.h"
#import "Alarm+Requests.h"
#import "GuardianInvitation.h"
#import "CheckIn.h"
#import "SLDataManager.h"
#import "SLNotificationCenterNotifications.h"
#import "GuardianInvitationStatus.h"
#import "UserToUserInvitationStatus.h"
#import "SlideMenuMainViewController.h"
#import "AlarmViewController.h"
#import "EventsTableViewController.h"
#import "CheckInViewController.h"
#import "LeftMenuTableViewController.h"
#import "SLError.h"
#import "SafeletUnitManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>
#import "FollowMe.h"
#import "HomeViewController.h"

@interface SLPushNotificationManager()
@property (strong, nonatomic) NSDictionary *lastHandledPushNotification;
@end

@implementation SLPushNotificationManager

+ (instancetype)sharedManager {
    static SLPushNotificationManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
    });
    
    return manager;
}

#pragma mark - notification registration

+ (void)setChannelsForCurrentInstallation:(NSArray * _Nonnull)channels completion:(void (^)(NSError * _Nonnull))completion {
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation.channels = channels;
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSLog(@"🖕🏻 - current installation did set channels: %@ succeeded: %d, error: %@", channels, succeeded, error);
        if (completion) {
            completion(error);
        }
    }];
}

+ (void)registerUserForPushNotifications:(User *)user completion:(void (^)(NSError * _Nonnull))completion {
    [self setChannelsForCurrentInstallation:@[user.objectId] completion:completion];
}

+ (void)unregisterDeviceFromNotificationsWithCompletion:(void (^)(NSError * _Nonnull))completion {
    [self setChannelsForCurrentInstallation:@[] completion:completion];
}

#pragma mark - notification handling

- (void)handlePushNotificationDictionaryPayload:(NSDictionary *)pushNotificationDict
                                      showAlert:(BOOL)showAlert {
    if ([pushNotificationDict isEqualToDictionary:self.lastHandledPushNotification]) {
        //        return;
    }
    
    self.lastHandledPushNotification = pushNotificationDict;
    PushNotification *pushNotification = [PushNotification createFromDictionary:pushNotificationDict];
    
    [self getPushNotificationObject:pushNotification
                         completion:^(id object, NSError *error) {
        NSString *format = NSLocalizedStringWithDefaultValue([pushNotification localizedKey],
                                                             @"Localizable",
                                                             [NSBundle mainBundle],
                                                             [pushNotification defaultMessage], nil);
        
        NSString *message = [NSString stringWithFormat:format arguments:[pushNotification localizedArgs]];
        NSString *loc_key = [pushNotification localizedKey];
        
        if (showAlert) { // show alertview if app is in foreground
            
            if (error || !object) {
                if([loc_key isEqualToString:@"POLICY_NOTIFICATION"]){
                    [UIAlertController showPushNotificationAlertWithMessageForFollowMe:message isShowDismiss:(BOOL)NO handler:^(BOOL shouldShowDetails) {
                        if (shouldShowDetails == YES) {
                            [self showRelevantScreenForUser:object];
                            //                                                 [[SLDataManager sharedManager] handlePushNotificationUserPolicy:object];
                        }
                    }];
                    return;
                }else{
                    [UIAlertController showAlertWithMessage:message];
                }
                
                return;
            }
            
            [self handlePushNotificationObject:object notification:pushNotification];
            
            if ([self canViewDetailsForNotificationObject:object]) {
                if ([object isKindOfClass:[FollowMe class]]) {
                    if([loc_key isEqualToString:@"STOP_FOLLOW_USER"] || [loc_key isEqualToString:@"STOP_FOLLOW_ME"]){
                        
                        [UIAlertController showPushNotificationAlertWithMessageForFollowMe:message isShowDismiss:(BOOL)NO handler:^(BOOL shouldShowDetails) {
                            if (shouldShowDetails == YES) {
                                [self showRelevantScreenForPushNotificationObject:object];
                            }
                        }];
                    }else if([loc_key isEqualToString:@"START_FOLLOW_ME"]){
                        [UIAlertController showPushNotificationAlertWithMessageForFollowMe:message isShowDismiss:(BOOL)YES handler:^(BOOL shouldShowDetails) {
                            if (shouldShowDetails == YES) {
                                [self showRelevantScreenForPushNotificationObject:object];
                            }
                        }];
                    }
                }else{
                    [UIAlertController showPushNotificationAlertWithMessage:message
                                                                    handler:^(BOOL shouldShowDetails) {
                        if (shouldShowDetails == YES) {
                            [self showRelevantScreenForPushNotificationObject:object];
                        }
                    }];
                }
                
            } else {
                [UIAlertController showAlertWithMessage:message];
            }
        } else if([loc_key isEqualToString:@"POLICY_NOTIFICATION"]){
            [UIAlertController showPushNotificationAlertWithMessageForFollowMe:message isShowDismiss:(BOOL)NO handler:^(BOOL shouldShowDetails) {
                if (shouldShowDetails == YES) {
                    [self showRelevantScreenForUser:object];
                }
            }];
        }else if (object) { // app opened from push notification
            [self handlePushNotificationObject:object notification:pushNotification];
            [self showRelevantScreenForPushNotificationObject:object];
        }
    }];
}

- (void)handlePushNotificationObject:(id)object notification:(PushNotification *)notification {
    if ([object isKindOfClass:[Alarm class]]) {
        [[SLDataManager sharedManager] handlePushNotificationAlarm:object joinUserName:notification.localizedArgs.firstObject];
    } else if ([object isKindOfClass:[GuardianInvitation class]]) {
        [[SLDataManager sharedManager] handlePushNotificationInvitation:object];
    } else if ([object isKindOfClass:[FollowMe class]]) {
        [[SLDataManager sharedManager] handlePushNotificationFollowMe:object];
    } else if ([object isKindOfClass:[User class]]) {
        [[SLDataManager sharedManager] handlePushNotificationUserPolicy:object];
    } else {
        [[SLDataManager sharedManager] handlePushNotificationCheckIn:object];
    }
}

#pragma mark - Show relevant screen

- (void)showRelevantScreenForPushNotificationObject:(id)object {
    if ([object isKindOfClass:[Alarm class]]) {
        [self showRelevantScreenForAlarm:object];
    } else if ([object isKindOfClass:[GuardianInvitation class]]) {
        [self showRelevantScreenForGuardianInvitation:object];
    } else if ([object isKindOfClass:[FollowMe class]]) {
        [self showRelevantScreenForFollowMe:object];
    } else if ([object isKindOfClass:[User class]]) {
        [self showRelevantScreenForUser:object];
        
        PushNotification *pushNotification = [PushNotification createFromDictionary:self.lastHandledPushNotification];
        [self handlePushNotificationObject:object notification:pushNotification];
    } else {
        [self showRelevantScreenForCheckIn:object];
    }
}

- (void)showRelevantScreenForAlarm:(Alarm *)alarm {
    SlideMenuMainViewController *menuVC = [SlideMenuMainViewController currentMenu];
    
    // the active alarm belongs to the current user => show the Alarm section
    if (alarm.isActive && [alarm.user.objectId isEqualToString:[User currentUser].objectId]) {
        [menuVC.leftMenu performSegueWithIdentifier:menuVC.alarmSegueIdentifier
                                             sender:nil];
    } else if (alarm.isActive) { // the active alarm belongs to someone else => show events alarm details
        [menuVC.leftMenu performSegueWithIdentifier:menuVC.eventsSegueIdentifier
                                             sender:nil];
        
        // not a dummy VC anymore, since we push it on the stack
        
        [alarm checkIfUserIsParticipant:[User currentUser]
                             completion:^(BOOL isParticipant, NSError * _Nullable error) {
            BOOL shouldShowAlarmButton = error ? NO : !isParticipant;
            
            id pulley = [Utils createChatAlarmControllerWithAlarm:alarm
                                        shouldShowJoinAlarmButton:shouldShowAlarmButton];
            [menuVC.currentActiveNVC pushViewController:pulley animated:YES];
        }];
    }
}

- (void)showRelevantScreenForCheckIn:(CheckIn *)checkIn {
    SlideMenuMainViewController *menuVC = [SlideMenuMainViewController currentMenu];
    
    [menuVC.leftMenu performSegueWithIdentifier:menuVC.eventsSegueIdentifier
                                         sender:nil];
    
    EventsTableViewController *vc = [menuVC.currentActiveNVC.viewControllers lastObject]; // get the just pushed eventsTVC
    vc.selectedEventContentType = EventContentTypeCheckIns;
    
    CheckInViewController *checkinVC = [CheckInViewController createForUserCheckIn:checkIn];
    [menuVC.currentActiveNVC pushViewController:checkinVC animated:NO];
}

- (void)showRelevantScreenForGuardianInvitation:(GuardianInvitation *)invitation {
    if ([invitation.status isEqualToString:kGuardianInvitationStatusPending]) { // if we received an invitation
        SlideMenuMainViewController *menuVC = [SlideMenuMainViewController currentMenu];
        
        [menuVC.leftMenu performSegueWithIdentifier:menuVC.eventsSegueIdentifier
                                             sender:nil];
        
        EventsTableViewController *vc = [menuVC.currentActiveNVC.viewControllers lastObject]; // get the just pushed eventsTVC
        vc.selectedEventContentType = EventContentTypeInvitations;
    }
}
- (void)showRelevantScreenForFollowMe:(FollowMe *)followMe {
    SlideMenuMainViewController *menuVC = [SlideMenuMainViewController currentMenu];
    
    [menuVC.leftMenu performSegueWithIdentifier:menuVC.homeSegueIdentifier
                                         sender:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    HomeViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    
    PushNotification *pushNotification = [PushNotification createFromDictionary:self.lastHandledPushNotification];
    
    NSString *loc_key = [pushNotification localizedKey];
    
    if([loc_key isEqualToString:@"STOP_FOLLOW_USER"]){
        vc.currentFollowObjectId = @"";
    }else if([loc_key isEqualToString:@"STOP_FOLLOW_ME"]){
        vc.currentUserFollowObjectId = @"";
    }else if([loc_key isEqualToString:@"START_FOLLOW_ME"]){
        vc.currentUserFollowObjectId = followMe.objectId;
    }
    [menuVC.currentActiveNVC popToRootViewControllerAnimated:YES];
}
- (void)showRelevantScreenForUser:(User *)user {
    SlideMenuMainViewController *menuVC = [SlideMenuMainViewController currentMenu];
    
    [menuVC.leftMenu performSegueWithIdentifier:menuVC.homeSegueIdentifier
                                         sender:nil];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    HomeViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
    vc.isShowPolicyView = true;
    PushNotification *pushNotification = [PushNotification createFromDictionary:self.lastHandledPushNotification];
    
    NSString *loc_key = [pushNotification localizedKey];
    
    if([loc_key isEqualToString:@"POLICY_NOTIFICATION"]){
        vc.currentFollowObjectId = @"";
    }
    vc.isShowPolicyView = true;
    vc.viewPolicy.hidden = false;
    NSArray *arr = [menuVC.currentActiveNVC viewControllers];
    for (HomeViewController *vss  in arr) {
        if([[vss class] isEqual:[vc class]]){
            vss.isShowPolicyView = true;
            [menuVC.currentActiveNVC popToViewController:vss animated:true];
            break;
        }
    }
    //    [menuVC.currentActiveNVC popToRootViewControllerAnimated:YES];
}
#pragma mark - Utils

- (void)getPushNotificationObject:(PushNotification *)pushNotification
                       completion:(void(^)(id object, NSError *error))completion {
    if (pushNotification.objectId && pushNotification.className) {
        PFQuery *query = [PFQuery queryWithClassName:pushNotification.className];
        [query includeKey:@"user"]; // for alarm, checkin, guardian invite
        [query includeKey:@"stopAlarmReason"]; // for alarm
        [query includeKey:@"fromUser"]; // for guardian invite
        [query includeKey:@"toUser"]; // for guardian invite
        [query getObjectInBackgroundWithId:pushNotification.objectId
                                     block:^(PFObject * _Nullable object, NSError * _Nullable error) {
            if (completion) {
                completion(object, error);
            }
        }];
    } else {
        NSString *msg = NSLocalizedString(@"The push notification is missing required payload data", nil);
        NSError *err = [SLError errorWithCode:SLErrorCodeMissingPushNotificationData failureReason:msg];
        completion(nil, err);
    }
}

- (BOOL)canViewDetailsForNotificationObject:(id)object {
    if ([object isKindOfClass:[Alarm class]]) {
        Alarm *alarm = object;
        return alarm.isActive;
    } else if ([object isKindOfClass:[GuardianInvitation class]]) {
        GuardianInvitation *invite = object;
        if ([invite getInvitationStatus] == GuardianInvitationStatusPending) {
            return YES;
        }
        return NO;
    } else if ([object isKindOfClass:[CheckIn class]]) {
        return YES;
    }else if ([object isKindOfClass:[FollowMe class]]) {
        return YES;
    }else if ([object isKindOfClass:[User class]]) {
        return YES;
    }
    
    return NO;
}

@end
