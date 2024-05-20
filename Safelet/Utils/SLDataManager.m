//
//  SLDataManager.m
//  Safelet
//
//  Created by Alex Motoc on 03/12/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "GuardianInvitation.h"
#import "GetConnectionsManager.h"
#import "GetPhoneContactsManager.h"
#import "Alarm.h"
#import "PhoneContact.h"
#import "SLDataManager.h"
#import "User+Requests.h"
#import "SLNotificationCenterNotifications.h"
#import "SafeletUnitManager.h"
#import "SyncContactsRequest.h"
#import "Utils.h"
#import <APAddressBook/APContact.h>
#import "FollowMe.h"

static NSString * const kIncludeHistoricEventsKey = @"historicEvents";
static NSString * const kPresentedNotificationsCount = @"notificationsCount";

@interface SLDataManager ()
@property (nonatomic, readwrite) NSInteger importantEventsCount;
@end

@implementation SLDataManager

+ (instancetype)sharedManager {
    static SLDataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
        
        [[NSNotificationCenter defaultCenter] addObserver:manager
                                                 selector:@selector(fetchEventsForAppWillEnterForeground)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];
    });
    
    return manager;
}

- (void)clearCachedData {
    self.importantEventsCount = 0;
    _events = nil;
    _guardedUsers = nil;
    _guardianUsers = nil;
    _phoneContactsMatched = nil;
    _phoneContactsSimple = nil;
    _didLoadMyConnections = NO;
}

- (void)setIncludeHistoricEvents:(BOOL)includeHistoricEvents {
    [[NSUserDefaults standardUserDefaults] setBool:includeHistoricEvents forKey:kIncludeHistoricEventsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)includeHistoricEvents {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIncludeHistoricEventsKey];
}

#pragma mark - MyConnections data handling

- (void)fetchConnectionsWithCompletion:(void (^)(NSArray *, NSArray *, NSError *))completion {
    [[GetConnectionsManager sharedManager] fetchConnectionsWithCompletion:^(NSArray *guardians, NSArray *guarded, NSError *error) {
        self->_guardianUsers = [NSMutableArray arrayWithArray:guardians];
        self->_guardedUsers = [NSMutableArray arrayWithArray:guarded];
        self->_didLoadMyConnections = YES;
        
        if (completion) {
            completion(guardians, guarded, error);
        }
    }];
}

- (void)removeConnection:(User *)user isGuardian:(BOOL)isGuardian {
    if (isGuardian) {
        NSMutableArray *aux = [self.guardianUsers mutableCopy];
        if ([aux indexOfObject:user] != NSNotFound) {
            [aux removeObject:user];
        }
        _guardianUsers = aux;
    } else {
        NSMutableArray *aux = [self.guardedUsers mutableCopy];
        if ([aux indexOfObject:user] != NSNotFound) {
            [aux removeObject:user];
        }
        _guardedUsers = aux;
    }
    
    PhoneContact *contact = [self phoneContactForParseUserObjectId:user.objectId];
    if (isGuardian) {
        [contact updateStatus:PhoneContactStatusUninvited];
    }
    
    [self fetchEventsForAppWillEnterForeground];
}

- (void)handleNewConnection:(User *)user isGuardian:(BOOL)isGuardian {
    if (isGuardian) {
        NSMutableArray *aux = [self.guardianUsers mutableCopy];
        if ([aux indexOfObject:user] == NSNotFound) {
            [aux addObject:user];
        }
        _guardianUsers = aux;
    } else {
        NSMutableArray *aux = [self.guardedUsers mutableCopy];
        if ([aux indexOfObject:user] == NSNotFound) {
            [aux addObject:user];
        }
        _guardedUsers = aux;
    }
    
    PhoneContact *contact = [self phoneContactForParseUserObjectId:user.objectId];
    if (isGuardian) {
        [contact updateStatus:PhoneContactStatusGuardian];
    }
    
    [self fetchEventsForAppWillEnterForeground];
}

#pragma mark - Contacts

- (void)fetchPhoneContactsWithCompletion:(void (^)(NSArray<PhoneContact *> * _Nonnull, NSError * _Nonnull))completion {
    [GetPhoneContactsManager fetchPhoneContactsMatchedWithParseUsers:^(NSArray<PhoneContact *> *contacts, NSError *error) {
        if (error == nil) {
            self->_phoneContactsMatched = contacts;
        }
        
        if (completion) {
            completion(contacts, error);
        }
    }];
}

- (void)syncContactsListWithCompletion:(void (^)(NSError * _Nullable))completion {
    [GetPhoneContactsManager fetchPhoneContacts:^(NSArray<PhoneContact *> *contacts, NSError *error) {
        if (error == nil) {
            // first sync the local contacts
            
            NSMutableDictionary *contactsDict = [NSMutableDictionary dictionary];
            for (PhoneContact *contact in contacts) {
                NSString *normalizedPhone = [contact.phoneNumber normalizedPhoneNumberWithDefaultCountryCode:[User currentUser].phoneCountryCode];
                contactsDict[normalizedPhone] = [contact formattedName];
            }
            self->_phoneContactsSimple = contactsDict;
        }
        
        // now sync contacts on server
        SyncContactsRequest *request = [SyncContactsRequest requestWithUser:[User currentUser] contactsList:contacts];
        [request setRequestCompletionBlock:^(id  _Nullable response, NSError * _Nullable error) {
            NSLog(@"contacts synced with response: %@; error: %@", response, error);
            if (completion) {
                completion(error);
            }
        }];
        
        [request runRequest];
    }];
}

#pragma mark - Events data handling

- (void)fetchEventsWithProgressIndicator:(BOOL)showProgressIndicator
                              completion:(void (^)(EventsList * _Nullable, NSUInteger, NSError * _Nullable))completion {
    [[User currentUser] fetchEvents:self.includeHistoricEvents
              withProgressIndicator:showProgressIndicator
                         completion:^(EventsList * _Nullable events, NSUInteger importantEventsCount, NSError * _Nullable error) {
                             self->_events = events;
                             self.importantEventsCount = importantEventsCount;
                             
                             if (completion) {
                                 completion(events, importantEventsCount, error);
                             }
                         }];
}

- (void)handlePendingInvitation:(GuardianInvitation *)invitation {
    NSMutableArray *aux = [self.events.invites mutableCopy];
    if ([aux indexOfObject:invitation] != NSNotFound) {
        [aux removeObject:invitation];
    }
    [aux insertObject:invitation atIndex:0];
    self.events.invites = aux;
}

- (void)handleCancelInvitation:(GuardianInvitation *)invitation {
    if (self.includeHistoricEvents == NO) {
        NSMutableArray *aux = [self.events.invites mutableCopy];
        if ([aux indexOfObject:invitation] != NSNotFound) {
            [aux removeObject:invitation];
        }
        self.events.invites = aux;
    }
}

- (void)handleStopAlarm:(Alarm *)alarm {
    if (self.includeHistoricEvents == NO || [self currentUserIsGuardingUser:alarm.user] == NO) {
        NSMutableArray *aux = [self.events.alarms mutableCopy];
        if ([aux indexOfObject:alarm] != NSNotFound) {
            [aux removeObject:alarm];
        }
        self.events.alarms = aux;
    }
    
    if (self.importantEventsCount - 1 == self.events.importantEventsCount) {
        self.importantEventsCount -= 1;
    }
}

#pragma mark - Guardian Network handling

- (void)setUserIsCommunityGuardian:(BOOL)isCommunityGuard
                        completion:(void(^)(BOOL success, NSError *error))completion {
    [[User currentUser] setUserIsCommunityGuardian:isCommunityGuard
                                        completion:^(BOOL success, NSError * _Nullable error) {
                                            if (success) {
                                                // update events list because new alarms might show up
                                                [self fetchEventsWithProgressIndicator:NO
                                                                            completion:nil];
                                            }
                                            
                                            if (completion) {
                                                completion(success, error);
                                            }
                                        }];
}

#pragma mark - Push Notification objects handling

- (void)handlePushNotificationAlarm:(Alarm *)alarm joinUserName:(NSString *)name {
    if (alarm.isActive && [alarm.user.objectId isEqualToString:[User currentUser].objectId] == NO) {
        NSMutableArray *aux = [self.events.alarms mutableCopy];
        if ([aux indexOfObject:alarm] != NSNotFound) {
            [aux removeObject:alarm];
        }
        [aux insertObject:alarm atIndex:0];
        self.events.alarms = aux;
        
        if (self.importantEventsCount + 1 == self.events.importantEventsCount) {
            self.importantEventsCount += 1;
        }
    } else if (alarm.isActive && [alarm.user.objectId isEqualToString:[User currentUser].objectId] == YES) { // joined alarm
        [[SafeletUnitManager shared] performJoinAlarmConfirmationWithUserName:name completion:nil];
    } else {
        [self handleStopAlarm:alarm];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SLReloadDataNotification object:nil];
}

- (void)handlePushNotificationCheckIn:(CheckIn *)checkIn {
    NSMutableArray *aux = [self.events.checkIns mutableCopy];
    if ([aux indexOfObject:checkIn] == NSNotFound) {
        [aux insertObject:checkIn atIndex:0];
    }
    self.events.checkIns = aux;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SLReloadDataNotification object:nil];
}

- (void)handlePushNotificationInvitation:(GuardianInvitation *)invitation {
    switch ([invitation getInvitationStatus]) {
        case GuardianInvitationStatusNone: {
            User *user = invitation.toUser;
            BOOL isGuardian = YES;
            
            if ([user.objectId isEqualToString:[User currentUser].objectId]) {
                user = invitation.fromUser;
                isGuardian = NO;
            }
            
            [self removeConnection:user isGuardian:isGuardian];
            [self handleCancelInvitation:invitation];
            break;
        }
        case GuardianInvitationStatusPending:
            [self handlePendingInvitation:invitation];
            break;
        case GuardianInvitationStatusAccepted:
            [self handleNewConnection:invitation.toUser isGuardian:YES];
            break;
        case GuardianInvitationStatusRejected: {
            PhoneContact *contact = [self phoneContactForParseUserObjectId:invitation.toUser.objectId];
            [contact updateStatus:PhoneContactStatusUninvited];
            break;
        }
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SLReloadDataNotification object:nil];
    [self fetchEventsForAppWillEnterForeground];
}
- (void)handlePushNotificationFollowMe:(FollowMe *)followMe {
    NSString *objectId = followMe.objectId;
    if (objectId != nil) {
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SLReloadDataNotification object:nil];
}

- (void)handlePushNotificationUserPolicy:(User *)user {
    [[NSNotificationCenter defaultCenter] postNotificationName:SLReloadDataNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLUserPolicyNotification object:nil];
}

#pragma mark - Notification Center handling

- (void)fetchEventsForAppWillEnterForeground {
    [self fetchEventsWithProgressIndicator:NO
                                completion:^(EventsList * _Nullable events, NSUInteger importantEventsCount, NSError * _Nullable error) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:SLReloadDataNotification object:nil];
                                }];
}

#pragma mark - Utils

- (PhoneContact *)phoneContactForParseUserObjectId:(NSString *)objectId {
    for (PhoneContact *contact in self.phoneContactsMatched) {
        if ([contact.userObjectId isEqualToString:objectId]) {
            return contact;
        }
    }
    
    return nil;
}

- (BOOL)currentUserIsGuardingUser:(User *)user {
    NSArray *objectIds = [self.guardedUsers valueForKey:@"objectId"];
    if ([objectIds containsObject:user.objectId]) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Getters/setters

- (void)setPresentedLowBatteryNotificationsCount:(NSInteger)presentedLowBatteryNotificationsCount {
    [[NSUserDefaults standardUserDefaults] setInteger:presentedLowBatteryNotificationsCount forKey:kPresentedNotificationsCount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)presentedLowBatteryNotificationsCount {
    return  [[NSUserDefaults standardUserDefaults] integerForKey:kPresentedNotificationsCount];
}


@end
