//
//  AlarmViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/1/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "AlarmViewController.h"
#import "SLAlarmManager.h"
#import "Alarm+Requests.h"
#import "AlarmRecordingChunk.h"
#import "Utils.h"
#import "User+Requests.h"
#import "SLErrorHandlingController.h"
#import "SLDataManager.h"
#import "SLAlarmPlaybackManager.h"
#import "SlideMenuMainViewController.h"
#import "SLAlarmRecordingManager.h"
#import "MarkerIcon.h"
#import "StopAlarmReasonViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <GoogleMaps/GoogleMaps.h>
#import <SDWebImage/UIImageView+WebCache.h>

static NSTimeInterval const kTimerUpdateInterval = 5; // fire timer every 5 seconds
static NSString * const kAlarmViewControllerIdentifier = @"alarmViewController";
static NSString * const kStopAlarmReasonSegueIdentifier = @"stopAlarmReasonSegue";

@interface AlarmViewController ()
@property (strong, nonatomic) Alarm *alarm;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSTimer *timer; // used to update the UI periodically
@property (strong, nonatomic) MBProgressHUD *hud;
@property (nonatomic) BOOL didShowInitialProgressHUD; // flag that allows us to show the progress HUD only once, while the initial data is loaded
@property (nonatomic) NSInteger prevParticipantsCount; // used to update map view zoom when new participants join the alert
@end

@implementation AlarmViewController

+ (instancetype)createWithAlarm:(Alarm *)alarm {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AlarmViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kAlarmViewControllerIdentifier];
    vc.alarm = alarm;
    return vc;
}

#pragma ViewController Lifecycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if (!self.alarm) {
            self.alarm = [SLAlarmManager sharedManager].alarm;
        }
    }
    return self;
}

- (void)dealloc {
    [self stopTimer];
}
- (void)callCoder{
    if (!self.alarm) {
        self.alarm = [SLAlarmManager sharedManager].alarm;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.alarm, @"Alarm object must not be nil");
    
    self.prevParticipantsCount = -1; // default value
    
    [self initializeUI];
    [self initializeTimedUpdates];
    self.navigationController.navigationBar.backgroundColor = [UIColor blackColor];
    self.navigationItem.leftBarButtonItem = self.navigationController.parentViewController.navigationItem.leftBarButtonItem;
    
    //if location permission is not enabled then give message 
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"App Permission Denied"
                                                                       message:@"To re-enable, please go to Settings and turn on Location Service for this app."                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if( UIApplicationOpenSettingsURLString){
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil) style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (parent == nil) {
        if ([SLAlarmPlaybackManager sharedManager].isPlaying) {
            [[SLAlarmPlaybackManager sharedManager] stopPlayback];
        }
        
        [self stopTimer]; // stop timed UI updates when the view is dissappearing
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if ([SLAlarmPlaybackManager sharedManager].isPlaying) {
        [[SLAlarmPlaybackManager sharedManager] stopPlayback];
    }
    
    [self stopTimer]; // stop timed UI updates when the view is dissappearing
}

#pragma mark - Initializations

- (void)initializeUI {
    User *currentUser = [User currentUser];
    
    if ([self.alarm.user.objectId isEqualToString:currentUser.objectId] == NO) { // some other user dispatched the alarm
        self.title = [self.alarm.user.name stringByAppendingString:NSLocalizedString(@" needs your help!", nil)];
        
        // hide "Stop Alarm" button, since this alarm is not dispatched by the current user, so he has no control
        self.navigationItem.rightBarButtonItem = nil;
    }
}

/**
 *	Start timer services. Timed updates enable us to display the list of participants and their location
 */
- (void)initializeTimedUpdates {
    [self stopTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerUpdateInterval
                                                  target:self
                                                selector:@selector(timerUpdate)
                                                userInfo:nil
                                                 repeats:YES];
    
    // force the first update, so we don't wait for the timer to fire after the specified interval
    [self timerUpdate];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - Timer update

- (void)timerUpdate {
    // if we didn't load the participants data yet, and no progress hud is present
    if (![MBProgressHUD HUDForView:self.view] && !self.didShowInitialProgressHUD) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    // firstly update the alarm object (which could be modified by another instance of the app)
    [self.alarm refreshAlarmDataInBackgroundWithCompletion:^(Alarm *alarm, NSError * _Nullable error) {
        if (error) {
            return; // error updating alarm object; stop any further actions
        }
        
        if (self.alarm.isActive) { // if the alarm is still active, show the list of participants and update playback
            SLAlarmPlaybackManager *manager = [SLAlarmPlaybackManager sharedManager];
            
            if (manager.isPlaying) {
                [self.alarm fetchLastRecordingChunkWithCompletion:^(AlarmRecordingChunk * _Nullable chunk, NSError * _Nullable error) {
                    if (chunk) {
                        [manager addChunkToPlayback:chunk];
                    }
                }];
            }
            
            [self.alarm fetchParticipantsWithProgressIndicator:NO
                                                    completion:^(NSArray<User *> * _Nullable participants,
                                                                 NSError * _Nullable error) {
                                                        // hide progress hud
                                                        if ([MBProgressHUD HUDForView:self.view]) {
                                                            self.didShowInitialProgressHUD = YES;
                                                            [MBProgressHUD hideHUDForView:self.view
                                                                                 animated:YES];
                                                        }
                                                        
                                                        [self updateUIWithParticipants:participants];
                                                    }];
        } else if (![self.alarm.user.objectId isEqualToString:[User currentUser].objectId]) {
            // hide progress hud
            if ([MBProgressHUD HUDForView:self.view]) {
                [MBProgressHUD hideHUDForView:self.view
                                     animated:YES];
            }
            
            /**
             *  Otherwise, if the alarm is not active and the current user isn't the dispatcher one,
             *  it means the dispatcher has stopped it, so we can show a message and close this view controller
             *
             */
            [UIAlertController showSuccessAlertWithMessage:NSLocalizedString(@"The dispatcher has cancelled the alarm",
                                                                       @"Message shown to a user that is viewing an alarm from the events section")];
            
            [self stopTimer];
            
            [[SLDataManager sharedManager] handleStopAlarm:self.alarm];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

/**
 *	Add markers on the map for each participant and for the user that dispatched the alarm
 *
 *	@param participants	array of User objects that are participating to the alarm
 */
- (void)updateUIWithParticipants:(NSArray <User *> *)participants {
    [self.mapView clear];
    
    GMSMarker *dispatcherMarker = [self getMarkerForUser:self.alarm.user];
    
    GMSMutablePath *path = [GMSMutablePath path];
    [path addCoordinate:dispatcherMarker.position];
    
    // add the markers for participants to the map
    for (User *user in participants) {
        GMSMarker *marker = [self getMarkerForUser:user];
        [path addCoordinate:marker.position];
    }
    
    // if a participant left or joined the alarm, zoom the map such that we can see all the participants
    if (participants.count != self.prevParticipantsCount) {
        self.prevParticipantsCount = participants.count;
        
        if (participants.count > 0) { // if we have participants
            // zoom the camera to view them and also the dispatcher user
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
            GMSCameraUpdate *cameraUpdate = [GMSCameraUpdate fitBounds:bounds withPadding:80];
            
            [self.mapView animateWithCameraUpdate:cameraUpdate];
        } else { // the only participant showed on the map will be the dispatcher user
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:dispatcherMarker.position.latitude
                                                                    longitude:dispatcherMarker.position.longitude
                                                                         zoom:16];
            self.mapView.camera = camera;
        }
    }
}

#pragma mark - Utils

/**
 *	Creates, adds to self.mapView and returns a green marker for the specified user.
 *  If the provided user is the user that dispatched the alert, the marker color will be red (default).
 *
 *	@param user	User object
 *
 *	@return GMSMarker a marker
 */
- (GMSMarker *)getMarkerForUser:(User *)user {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(user.locationCoordinates.latitude,
                                                                   user.locationCoordinates.longitude);
    
    GMSMarker *marker = [GMSMarker markerWithPosition:coordinate];
    
    NSString *title = user.name;
    if ([user.objectId isEqualToString:[User currentUser].objectId]) {
        title = NSLocalizedString(@"You", nil);
    }
    
    marker.map = self.mapView;
    
    //use the green color for participants
    UIImage *icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
    if ([user.objectId isEqualToString:self.alarm.user.objectId]) { // if the marker is for the user that dispatched the alarm
        //set its color to red (dispatcher)
        icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
    }
    
    marker.iconView = [MarkerIcon markerViewWithLabelText:title
                                            labelMaxWidth:self.view.frame.size.width / 2
                                                  pinIcon:icon];
    
    marker.map = self.mapView;
    
    return marker;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kStopAlarmReasonSegueIdentifier]) {
        StopAlarmReasonViewController *stopAlarmVC = segue.destinationViewController;
        
        stopAlarmVC.dataSource = @[@(StopReasonTestAlarm), @(StopReasonAccidentalAlarm), @(StopReasonHelpNoLongerNeeded), @(StopReasonOther)];
        [stopAlarmVC setDismissCompletionBlock:^(StopReason reason, NSString *userDescription) {
            [self.alarm stopWithReason:reason reasonDescription:userDescription completion:^(BOOL success, NSError * _Nullable error) {
                if (success) {
                    [self stopTimer]; // stop timed UI updates when the alarm is stopped
                    [SLAlarmManager handleStopAlarm]; // handle alarm stop
                    
                    // when the alarm has been stopped, SlideMenuMainViewController has to change the content to MyConnections
                    SlideMenuMainViewController *slideMainVC = [SlideMenuMainViewController currentMenu];
                    [slideMainVC.leftMenu performSegueWithIdentifier:slideMainVC.homeSegueIdentifier
                                                              sender:nil];
//                    [slideMainVC.leftMenu performSegueWithIdentifier:slideMainVC.myConnectionsSegueIdentifier
//                                                              sender:nil];
                } else { // success == NO
                    if (error) { // if we have an error object, use its message
                        [SLErrorHandlingController handleError:error];
                    } else {
                        NSString *errMsg = NSLocalizedString(@"There was an error while stopping the alarm", nil);
                        [UIAlertController showErrorAlertWithMessage:errMsg];
                    }
                }
            }];
        }];
    }
}

#pragma mark - User Interaction

- (void)handleUserJoinAlarmAction:(void (^)(BOOL))completion {
    [[User currentUser] joinAlarmWithObjectId:self.alarm.objectId
                                   completion:^(BOOL success, NSError * _Nullable error) {
                                       if (success) {
                                           [self timerUpdate]; // force a UI update, since a new participant has joined
                                       } else { // error encountered
                                           if (error) {
                                               [SLErrorHandlingController handleError:error];
                                               
                                           } else {
                                               NSString *errMsg = NSLocalizedString(@"There was an error while joining the alarm", nil);
                                               [UIAlertController showErrorAlertWithMessage:errMsg];
                                           }
                                       }
                                       completion(success);
                                   }];
}

- (void)handleUserCallEmergencyAction {
    NSString *emergencyNumber = @"911";
    NSString *alertTitle = NSLocalizedString(@"Call 911?", nil);
    if ([[User currentUser].phoneCountryCode isEqualToString:@"+64"]) {
        alertTitle = NSLocalizedString(@"Call 111?", nil);
        emergencyNumber = @"111";
    }
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:alertTitle
                                                                        message:nil preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.alarm notifyParticipantsCurrentUserCalledEmergency:^(BOOL success, NSError * _Nullable error) {
            if (success) {
                [UIAlertController showSuccessAlertWithMessage:NSLocalizedString(@"Notified participants that emergency call was performed", nil)];
            } else {
                if (error) {
                    [SLErrorHandlingController handleError:error];
                } else {
                    [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Failed to notify participants that emergency call was performed", nil)];
                }
            }
        }];
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:emergencyNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }]];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)handleUserPlayAlarmAction:(void (^)(BOOL))stateChangedBlock {
    if ([SLAlarmRecordingManager sharedManager].isRecording) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Can't playback while recording. Please stop recording and try again", nil)];
        return;
    }
    
    SLAlarmPlaybackManager *manager = [SLAlarmPlaybackManager sharedManager];
    
    if (manager.isPlaying) {
        [manager stopPlayback];
        stateChangedBlock(NO);
        return;
    }
    
    [manager startPlayback:self.alarm stateChangedBlock:^(SLAlarmPlaybackState state) {
        if (state == SLAlarmPlaybackStateStartedSuccess) {
            stateChangedBlock(YES);
        } else if (state == SLAlarmPlaybackStateCompleted) {
            [manager stopPlayback];
            stateChangedBlock(NO);
        }
    }];
}

@end
