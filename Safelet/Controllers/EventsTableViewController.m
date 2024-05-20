//
//  EventsTableViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EventsTableViewController.h"
#import "EventsAlarmTableViewCell.h"
#import "EventsInviteTableViewCell.h"
#import "EventsCheckInTableViewCell.h"
#import "Alarm+Requests.h"
#import "GuardianInvitation.h"
#import "CheckIn.h"
#import "CheckInViewController.h"
#import "User+Requests.h"
#import "AlarmViewController.h"
#import "SLErrorHandlingController.h"
#import "SLDataManager.h"
#import "SlideMenuMainViewController.h"
#import "LeftMenuTableViewController.h"
#import "SLNotificationCenterNotifications.h"
#import "EventsHistoricAlarmTableViewCell.h"
#import "EventsHistoricInviteTableViewCell.h"
#import "PlayHistoricAlarmRecordingViewController.h"
#import "EventTypeSelectorView.h"
#import "Utils.h"

static NSString * const kPlayRecordingSegueIdentifier = @"playRecordingSegue";

@interface EventsTableViewController () <EventsInviteCellDelegate, EventsAlarmCellDelegate,
EventsHistoricAlarmCellDelegate, EventTypeSegmentedControlDelegate>
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UILabel *noEventsLabel;
@property (strong, nonatomic) EventTypeSelectorView *contentSelectorView;
@property (nonatomic) CGFloat alarmsContentOffsetY;
@property (nonatomic) CGFloat invitesContentOffsetY;
@property (nonatomic) CGFloat checkinsContentOffsetY;

@property (weak, nonatomic) IBOutlet UILabel *historicEventsLabel;
@end

static NSString * const kEventsViewControllerIdentifier = @"eventsVC";

@implementation EventsTableViewController

#pragma mark - ViewController LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDataSource:)
                                                 name:SLReloadDataNotification
                                               object:nil];
    
    [self populateControllerWithData];
    [self initializeTableView];
    
    [self fetchEvents:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI Configuration

- (void)initializeTableView {
    self.contentSelectorView = [EventTypeSelectorView createWithDelegate:self
                                                      defaultContentType:self.selectedEventContentType];
    
    // initialize pull-to-refresh
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(fetchEventsNoProgress)
                  forControlEvents:UIControlEventValueChanged];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView setDelaysContentTouches:NO];
    
    [self addNoEventsLabelIfNeeded];
}

- (void)addNoEventsLabelIfNeeded {
    if (self.dataSource.count == 0) {
        [self addNoEventsLabel];
    } else {
        self.tableView.backgroundView = nil;
    }
}

- (void)addNoEventsLabel {
    self.noEventsLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.noEventsLabel.text = NSLocalizedString(@"No events are available", nil);
    self.noEventsLabel.textAlignment = NSTextAlignmentCenter;
    self.noEventsLabel.numberOfLines = 0;
    self.tableView.backgroundView = self.noEventsLabel;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [EventTypeSelectorView viewHeight];
}

#pragma mark - Table view delegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.contentSelectorView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id element;
    @try {
        element = [self.dataSource objectAtIndex:indexPath.row];
    } @catch (NSException *exception) {
        return nil;
    }
    
    
    if ([element isKindOfClass:[GuardianInvitation class]]) {
        GuardianInvitation *invite = element;
        if ([invite isHistoric]) {
            EventsHistoricInviteTableViewCell *inviteCell = [tableView dequeueReusableCellWithIdentifier:[EventsHistoricInviteTableViewCell identifier]
                                                                                            forIndexPath:indexPath];
            
            [inviteCell populateWithGuardianInvitation:invite];
            return inviteCell;
        }
        
        EventsInviteTableViewCell *inviteCell = [tableView dequeueReusableCellWithIdentifier:[EventsInviteTableViewCell identifier]
                                                                                forIndexPath:indexPath];
        
        [inviteCell populateWithUser:element
                            delegate:self];
        return inviteCell;
    } else if ([element isKindOfClass:[CheckIn class]]) {
        EventsCheckInTableViewCell *checkInCell = [tableView dequeueReusableCellWithIdentifier:[EventsCheckInTableViewCell identifier]
                                                                                  forIndexPath:indexPath];
        
        [checkInCell populateWithCheckIn:element];
        return checkInCell;
    } else {
        Alarm *alarm = element;
        if ([alarm isHistoric]) {
            EventsHistoricAlarmTableViewCell *alarmCell = [tableView dequeueReusableCellWithIdentifier:[EventsHistoricAlarmTableViewCell identifier]
                                                                                          forIndexPath:indexPath];
            [alarmCell populateWithAlarm:alarm delegate:self];
            
            return alarmCell;
        }
        
        EventsAlarmTableViewCell *alarmCell = [tableView dequeueReusableCellWithIdentifier:[EventsAlarmTableViewCell identifier]
                                                                              forIndexPath:indexPath];
        
        [alarmCell populateWithAlarm:element
                            delegate:self];
        return alarmCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[self.tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[EventsCheckInTableViewCell class]]) {
        CheckInViewController *vc = [CheckInViewController createForUserCheckIn:[self.dataSource objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - User interaction

- (IBAction)didTapShowHistoricEventsButton:(UIButton *)sender {
    [SLDataManager sharedManager].includeHistoricEvents = ![SLDataManager sharedManager].includeHistoricEvents;
    [self updateHistoricEventsLabelText];
    [self fetchEvents:YES];
}

#pragma mark - Segues

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:kPlayRecordingSegueIdentifier]) {
        return NO;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kPlayRecordingSegueIdentifier]) {
        PlayHistoricAlarmRecordingViewController *dest = segue.destinationViewController;
        dest.alarm = sender;
    }
}

#pragma mark - EventTypeSegmentedControlDelegate

- (void)eventTypeSegmentedControl:(EventTypeSelectorView *)control didSelectContentType:(EventContentType)contentType {
    [self saveCurrentContentOffsetForEventType:self.selectedEventContentType];
    
    self.selectedEventContentType = contentType;
    
    [self updateDataSource:nil];
    [self performSelector:@selector(setTableViewContentOffsetForCurrentlySelectedEventType) withObject:nil afterDelay:0.05f];
}

- (void)setTableViewContentOffsetForCurrentlySelectedEventType {
    [self.tableView setContentOffset:[self contentOffsetForEventType:self.selectedEventContentType] animated:YES];
}

#pragma mark - EventsInviteCellDelegate

- (void)inviteCell:(EventsInviteTableViewCell *)inviteCell didSelectStatus:(SLGuardianInvitationResponseType)status {
    GuardianInvitation *invitation = inviteCell.guardianInvitation;
    
    NSString *successMessage = NSLocalizedString(@"You have rejected the invitation", @"Guardian invitation reject");
    if (status == SLGuardianInvitationResponseTypeAccepted) {
        successMessage = NSLocalizedString(@"You have accepted the invitation", @"Guardian invitation accept");
    }
    
    [[User currentUser] respondToGuardianInvitationFromUser:invitation.fromUser.objectId
                                               responseType:status
                                                 completion:^(BOOL success, NSError * _Nullable error) {
                                                     if (error) {
                                                         [SLErrorHandlingController handleError:error];
                                                         return;
                                                     }
                                                     
                                                     [UIAlertController showSuccessAlertWithMessage:successMessage];
                                                     [self fetchEvents:YES];
                                                     
                                                     if (status == SLGuardianInvitationResponseTypeAccepted) {
                                                         [[SLDataManager sharedManager] handleNewConnection:invitation.fromUser isGuardian:NO];
                                                     }
                                                 }];
}

#pragma mark - EventsHistoricAlarmCellDelegate

- (void)historicAlarmCellDidSelectPlayRecordingForAlarm:(Alarm *)alarm {
    [self performSegueWithIdentifier:kPlayRecordingSegueIdentifier sender:alarm];
}

#pragma mark - EventsAlarmCellDelegate

- (void)alarmCellDidSelectSeeDetails:(EventsAlarmTableViewCell *)cell {
    Alarm *alarm = cell.alarm;
    
    [alarm checkIfUserIsParticipant:[User currentUser]
                         completion:^(BOOL isParticipant, NSError * _Nullable error) {
                             if (error) {
                                 [SLErrorHandlingController handleError:error];
                             } else {
                                 // if a user is participant to the alarm, don't show the "join" button
                                 BOOL shouldShowAlarmButton = !isParticipant;
                                 
                                 id vc = [Utils createChatAlarmControllerWithAlarm:alarm
                                                          shouldShowJoinAlarmButton:shouldShowAlarmButton];
                                 [self.navigationController pushViewController:vc animated:YES];
                             }
                         }];
}

- (void)alarmCellDidSelectIgnoreAlarm:(EventsAlarmTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Alarm *alarm = self.dataSource[indexPath.row];
    
    [[User currentUser] ignoreAlarmWithObjectId:alarm.objectId
                                     completion:^(BOOL success, NSError * _Nullable error) {
                                         if (error) {
                                             [SLErrorHandlingController handleError:error];
                                             return;
                                         }
                                         
                                         [self fetchEvents:YES];
                                     }];
}

#pragma mark - Utils

- (void)resetSavedContentOffsets {
    self.alarmsContentOffsetY = 0;
    self.invitesContentOffsetY = 0;
    self.checkinsContentOffsetY = 0;
}

- (CGPoint)contentOffsetForEventType:(EventContentType)type {
    switch (type) {
        case EventContentTypeAlarms:
            return CGPointMake(0, self.alarmsContentOffsetY);
        case EventContentTypeInvitations:
            return CGPointMake(0, self.invitesContentOffsetY);
        case EventContentTypeCheckIns:
            return CGPointMake(0, self.checkinsContentOffsetY);
    }
}

- (void)saveCurrentContentOffsetForEventType:(EventContentType)type {
    switch (type) {
        case EventContentTypeAlarms:
            self.alarmsContentOffsetY = self.tableView.contentOffset.y;
            break;
        case EventContentTypeInvitations:
            self.invitesContentOffsetY = self.tableView.contentOffset.y;
            break;
        case EventContentTypeCheckIns:
            self.checkinsContentOffsetY = self.tableView.contentOffset.y;
            break;
    }
}

- (void)populateControllerWithData {
    if ([SLDataManager sharedManager].events) {
        [self updateDataSource:nil];
    } else {
        [self fetchEvents:YES];
    }
}

- (void)updateDataSource:(id)sender {
    BOOL shouldDelay = NO;
    if ([sender isKindOfClass:[NSNotification class]]) {
        shouldDelay = YES;
        [self resetSavedContentOffsets];
        self.tableView.contentOffset = CGPointZero;
    }
    
    EventsList *events = [SLDataManager sharedManager].events;
    if (self.selectedEventContentType == EventContentTypeAlarms) {
        self.dataSource = events.alarms;
    } else if (self.selectedEventContentType == EventContentTypeInvitations) {
        self.dataSource = events.invites;
    } else {
        self.dataSource = events.checkIns;
    }
    
    if (shouldDelay) {
        [self performSelector:@selector(reloadTableData) withObject:nil afterDelay:0.05f];
    } else {
        [self reloadTableData];
    }
}

- (void)updateHistoricEventsLabelText {
    NSString *aux = [SLDataManager sharedManager].includeHistoricEvents ? NSLocalizedString(@"ON", nil) : NSLocalizedString(@"OFF", nil);
    NSString *format = NSLocalizedString(@"Historic events: %@\nTap to change", nil);
    
    self.historicEventsLabel.text = [NSString stringWithFormat:format, aux];
}

- (void)reloadTableData {
    [self addNoEventsLabelIfNeeded]; // must be before table.reloadData
    [self updateHistoricEventsLabelText];
    
    [self.tableView reloadData];
}

- (void)fetchEventsNoProgress {
    [self fetchEvents:NO];
}

- (void)fetchEvents:(BOOL)showProgressIndicator {
    [self resetSavedContentOffsets];
    [[SLDataManager sharedManager] fetchEventsWithProgressIndicator:showProgressIndicator
                                                         completion:^(EventsList * _Nullable events,
                                                                      NSUInteger importantEventsCount,
                                                                      NSError * _Nullable error) {
                                                             if (error) {
                                                                 [self hideRefreshControl];
                                                                 [SLErrorHandlingController handleError:error];
                                                             } else {
                                                                 [self updateDataSource:nil];
                                                                 [self hideRefreshControl];
                                                             }
                                                         }];
}

- (void)hideRefreshControl {
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl performSelector:@selector(endRefreshing)
                                  withObject:nil
                                  afterDelay:0.1f];
    }
}

@end
