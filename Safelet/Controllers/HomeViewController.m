//
//  HomeViewController.m
//  Safelet
//
//  Created by Ram on 18/01/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "HomeViewController.h"
#import "Utils.h"
#import "CheckIn.h"
#import "SLLocationManager.h"
#import "SLErrorHandlingController.h"
#import "MarkerIcon.h"
#import "AlarmViewController.h"
#import "SlideMenuMainViewController.h"
#import "SLAlarmManager.h"
#import "User+Requests.h"
#import "User+Logout.h"
#import "SafeletUnitManager.h"
#import "ImHereViewController.h"
#import "FollowMeViewController.h"
#import "SLDataManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "SLNotificationCenterNotifications.h"

@interface HomeViewController (){
    NSArray *arrGuardians;
    
    NSTimer *timer;
}

@property (nonatomic) CLLocation *checkInLocation;
@property (strong, nonatomic) NSString *checkInLocationName;

@property (nonatomic) BOOL firstLocationUpdate;
@property (nonatomic) BOOL setupMarker;
@property (strong, nonatomic) CheckIn *userCheckIn;

@end
static NSString * const kHomeViewControllerIdentifier = @"HomeViewController";
static const NSInteger kZoomLevel = 13;
static NSString * const kTermConditionURL = @"https://safelet.com/terms-of-service/";

@implementation HomeViewController
@synthesize btnSOS,currentFollowObjectId,currentUserFollowObjectId;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    btnSOS.layer.cornerRadius = btnSOS.frame.size.width/2;
    btnSOS.clipsToBounds = true;
    
    self.checkInLocationName = [SLLocationManager getUnavailableLocationDefaultName]; // default
    
    self.checkInMarker = [GMSMarker new];
//    self.followUserMarker = [GMSMarker new];
    
    // initializations
    [self initializeMapView];
    [self initializeAccordingly];
    
    if(self.isShowPolicyView){
        self.viewPolicy.hidden = false;
        NSURL *url = [NSURL URLWithString:kTermConditionURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webKitPolicy loadRequest:request];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if([segue.identifier isEqualToString:@"im_here"]){
        ImHereViewController *dv = (ImHereViewController*)segue.destinationViewController;
        dv.checkInLocation = self.checkInLocation;
        dv.checkInLocationName = self.checkInLocationName;
    }else if([segue.identifier isEqualToString:@"follow_me"]){
        FollowMeViewController *dv = (FollowMeViewController*)segue.destinationViewController;
        dv.checkInLocation = self.checkInLocation;
        dv.checkInLocationName = self.checkInLocationName;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    self.title = @"HOME";
    
    // setup for scrollView to work properly
    self.edgesForExtendedLayout = UIRectEdgeNone;
        
    [self checkCurrentFollow];
    
    if(timer == nil){
        timer=[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(updateUserInMap) userInfo:nil repeats:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.mapView.delegate = nil;
    
    // removeObserver should not be executed if there is no observer added
    if (!self.userCheckIn) {
        SLLocationManager *locationManager = [SLLocationManager sharedManager];
        [locationManager setupNormalLocationTracking];
//        [locationManager removeObserver:self forKeyPath:@"currentLocation"];
        
//        [self.mapView removeObserver:self forKeyPath:@"myLocation"];
    }
}

- (IBAction)btnSOSPress:(id)sender {
    SlideMenuMainViewController *menuVC = [SlideMenuMainViewController currentMenu];
    
    // the active alarm belongs to the current user => show the Alarm section
//    [menuVC.leftMenu performSegueWithIdentifier:menuVC.alarmSegueIdentifier
//                                             sender:nil];
    
    SLAlarmManager *alarmManager = [SLAlarmManager sharedManager];
    
    if (alarmManager.alarm.isActive) {
        return;
    } else {
        [[User currentUser] dispatchAlarmWithCompletion:^(Alarm * _Nullable alarm,
                                                          NSError * _Nullable error) {
            if (error) {
                [SLErrorHandlingController handleError:error];
            } else if (!alarm) {
                NSString *errMsg = NSLocalizedString(@"There was an error dispatching the alert. Please try again",
                                                     @"An error occurred while dispatching an alert");
                [UIAlertController showErrorAlertWithMessage:errMsg];
            } else {
                [SLAlarmManager handleDispatchAlarm:alarm shouldPlaySound:YES];
                [[SafeletUnitManager shared] performDispatchAlarmConfirmation:^(NSError *error) {
                    if (error) {
                        [SLErrorHandlingController handleError:error];
                    }
                }];
                
                // in LeftMenuTableViewController prepareForSegue: we do customisation for AlarmViewController
                [menuVC.leftMenu performSegueWithIdentifier:menuVC.alarmSegueIdentifier
                                                                 sender:nil];
            }
        }];
    }
}

- (IBAction)btnAcceptPolicy:(id)sender {
    User *currentUser = [User currentUser];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    currentUser.isTermsConditionAccepted = true;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:window animated:YES];
        if (succeeded) {
            self.viewPolicy.hidden = true;
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", nil)
                                                                                     message:NSLocalizedString(@"Terms & condition accepted.",nil)
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [self.navigationController popViewControllerAnimated:YES];
                                                                 }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            // recover previous data after failed "save"
            currentUser.isTermsConditionAccepted = false;
            [currentUser saveEventually];
            
            [SLErrorHandlingController handleError:error];
        }
    }];
}

- (IBAction)btnFollowMePress:(id)sender {
    
}

- (IBAction)btnIMHerePress:(id)sender {
}

- (IBAction)btnStopFollowMePress:(id)sender {
//    NSString *followMeObjectId = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowMeObjectIdKeyPath];
    if(currentFollowObjectId == nil){
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // sends the check-in geoPoint, address, message to parse
    [[User currentUser] stopFollowMe:currentFollowObjectId completion:^(BOOL success, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        
        if (error) {
            [SLErrorHandlingController handleError:error];
        } else {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:kFollowMeObjectIdKeyPath];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self->currentFollowObjectId = @"";
            self->_viewGuardiansList.hidden = true;
            self->arrGuardians = nil;
            [self->_collectionViewGuardians reloadData];
            
            self->timer = nil;
        }
    }];
}

- (IBAction)btnStopFollowingUserPress:(id)sender {
//    NSString *followMeObjectId = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowUserObjectIdKeyPath];
    if(currentUserFollowObjectId == nil){
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // sends the check-in geoPoint, address, message to parse
    [[User currentUser] stopFollowUser:currentUserFollowObjectId completion:^(BOOL success, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        
        if (error) {
            [SLErrorHandlingController handleError:error];
        } else {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:kFollowMeObjectIdKeyPath];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self->currentUserFollowObjectId = @"";
            self->_viewFollowingUser.hidden = true;
            self->arrGuardians = nil;
            [self->_collectionViewGuardians reloadData];
            
            self->timer = nil;
        }
    }];
}
-(void)updateUserInMap{
    if(currentFollowObjectId != nil && currentFollowObjectId.length > 0){
        _viewGuardiansList.hidden = false;
        
        [self updateLocation:currentFollowObjectId];
    }else if(currentUserFollowObjectId != nil && currentUserFollowObjectId.length > 0){
        _viewFollowingUser.hidden = false;
        
        [self getUserLocation:currentUserFollowObjectId];
    }
        
}
-(void)checkCurrentFollow{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // sends the check-in geoPoint, address, message to parse
    [[User currentUser] checkCurrentFollow:^(NSArray * _Nullable response, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        NSLog(@"Point : %@",response);
        if (error) {
            [SLErrorHandlingController handleError:error];
        } else {
//            if([[response class] isKindOfClass:[NSDictionary class]]){
            if(response.count > 0){
                if(![[response valueForKey:@"followObjectId"] isEqualToString:@""]){
                    if([[response valueForKey:@"loginUserCreateFollow"] intValue] == 1){
                        self->currentFollowObjectId = [response valueForKey:@"followObjectId"];
                        NSLog(@"Point : %@",self->currentFollowObjectId);
                        self->_viewFollowingUser.hidden = true;
                        self->_viewGuardiansList.hidden = false;
                        [self getSelectedGuardians:self->currentFollowObjectId];
                        
                    }else if([[response valueForKey:@"loginUserCreateFollow"] intValue] == 0){
                        self->currentUserFollowObjectId = [response valueForKey:@"followObjectId"];
                        NSLog(@"Point : %@",self->currentUserFollowObjectId);
                        self->_viewFollowingUser.hidden = false;
                        self->_viewGuardiansList.hidden = true;
                        
                        [self getUserLocation:self->currentUserFollowObjectId];
                    }
                }else{
                    self->_viewFollowingUser.hidden = true;
                    self->_viewGuardiansList.hidden = true;
                }
            }else{
                self->_viewFollowingUser.hidden = true;
                self->_viewGuardiansList.hidden = true;
            }
//            PFObject *obj = [response objectAtIndex:0];
            
        }
    }];
}
-(void)getSelectedGuardians:(NSString*)followMeObjectId{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // we create a PFGeoPoint which will be sent to parse later
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.checkInLocation.coordinate.latitude
                                               longitude:self.checkInLocation.coordinate.longitude];
    
    // sends the check-in geoPoint, address, message to parse
    [[User currentUser] getFollowMeGuardians:point address:self.checkInLocationName aObjectId:followMeObjectId completion:^(NSArray * _Nullable guardians, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        NSLog(@"Point : %@",guardians);
        if (error) {
            [SLErrorHandlingController handleError:error];
        } else {
            self->arrGuardians = guardians;
            [self->_collectionViewGuardians reloadData];
        }
    }];
}
-(void)getUserLocation:(NSString*)followObjectId{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // sends the check-in geoPoint, address, message to parse
    [[User currentUser] getFollowUserLocation:followObjectId completion:^(NSArray * _Nullable followData, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        NSLog(@"Point : %@",followData);
        if (error) {
            [SLErrorHandlingController handleError:error];
        } else {
            
            PFObject *objFollow = (PFObject*)[followData valueForKey:@"follow"];
            PFObject *objUser = (PFObject*)[followData valueForKey:@"user"];
            self->_lblAddressUserFollowing.text = [objFollow objectForKey:@"locationName"];
            self->_lblNameUserFollowing.text = [objUser objectForKey:@"name"];
            
            PFGeoPoint *location = (PFGeoPoint*)[objFollow objectForKey:@"location"];
            CLLocation *LocationAtual = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
        
            [self placeMarkerForFollowUser:LocationAtual userName:[objUser objectForKey:@"name"]];
            
            // if user is not nil, populate IBOutlets with user info
            if (objUser) {
                User *user = (User*)objUser;
                [self->_imgUserFollowing sd_setImageWithURL:[NSURL URLWithString:user.userImage.url]
                             placeholderImage:[UIImage imageNamed:@"generic_icon"]];
            }
        }
    }];
}
-(void)updateLocation:(NSString*)followMeObjectId{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // we create a PFGeoPoint which will be sent to parse later
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.checkInLocation.coordinate.latitude
                                               longitude:self.checkInLocation.coordinate.longitude];
    NSLog(@"Point : %@",point);
    // sends the check-in geoPoint, address, message to parse
    [[User currentUser] updateFollowMeLocation:point address:self.checkInLocationName aObjectId:followMeObjectId completion:^(BOOL success, NSError * _Nullable error) {
        
        [hud hideAnimated:YES];
        if (error) {
            [SLErrorHandlingController handleError:error];
        } else {
            NSLog(@"Location updated");
        }
    }];
}
#pragma mark - Initializations

/**
 *  Method used in order to properly initialize the ViewController
 *  If we want to see the last check-in of an user it checks if check-in exists
 *  otherwise it knows that we want to check-in at current location.
 */
- (void)initializeAccordingly {
    // we check if we have a check-in & also an user
    
    // if we don't have a check-in, we want to track current location
    SLLocationManager *locationManager = [SLLocationManager sharedManager];
    [locationManager setupPreciseLocationTracking];
    [locationManager addObserver:self
                      forKeyPath:@"currentLocation"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    
    [self handleLocationManagerKVOTrigger:locationManager]; // force initial setup
    
//     observes the changes for "myLocation" keyPath
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
}

/**
 *  Method used in order to initalize the mapView.
 */
- (void)initializeMapView {
    self.mapView.delegate = self;
    
    // checks for check-in and if not, it enables current location and myLocationButton
    self.mapView.myLocationEnabled = YES;
    self.mapView.settings.myLocationButton = YES;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.checkInLocation.coordinate.latitude
                                                            longitude:self.checkInLocation.coordinate.longitude
                                                                 zoom:0]; // zoomIn method will do the zoom animation later
    self.mapView.camera = camera;
    self.mapView.settings.compassButton = YES; // adds the compass button on screen
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([object isKindOfClass:_mapView.class]) {
        [self handleMapViewKVOTrigger:object];
    } else if ([object isKindOfClass:[SLLocationManager class]]) {
        [self handleLocationManagerKVOTrigger:object];
    } else {
        NSLog(@"CHECK IN - KVO not handled for keyPath: %@ of object: %@", keyPath, object);
    }
}

- (void)handleMapViewKVOTrigger:(GMSMapView *)object {
    CLLocation *location = [object myLocation];
    CLLocationCoordinate2D target = CLLocationCoordinate2DMake(location.coordinate.latitude,
                                                               location.coordinate.longitude);
    if (!self.firstLocationUpdate) {
        self.firstLocationUpdate = YES;
        [self.mapView animateToLocation:target];
        
        // perform with delay to not be confused with any sort of glitch (by common user)
        [self performSelector:@selector(zoomIn) withObject:nil afterDelay:0.5];
    }
}

- (void)handleLocationManagerKVOTrigger:(SLLocationManager *)manager {
    // 1 - update location information
    _checkInLocation = manager.currentLocation;
    
    [SLLocationManager getAddressFromLocation:self.checkInLocation
                                   completion:^(BOOL success, NSString * _Nullable addressName) {
                                       if (success) {
                                           self.checkInLocationName = addressName;
                                       }
                                   }];
    
    
    // 2 - place marker
    if (!self.setupMarker) { // we ensure that we have only one marker on mapView
        [self placeCheckInMarker];
        self.setupMarker = YES;
    } else {
        _checkInMarker.position = _checkInLocation.coordinate;
    }
}

#pragma mark - GMSMapViewDelegate

- (BOOL)didTapMyLocationButtonForMapView:(GMSMapView *)mapView {
    // keyboard gets dismissed
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    // keyboard gets dismissed
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    // keyboard gets dismissed
}
#pragma mark - Utils
/**
 *  Method used in order to place the check-in marker
 *  for current location. This is used if the user wants
 *  to check-in.
 */
- (void)placeCheckInMarker {
    // checkInMarker is initialized
    self.checkInMarker = [GMSMarker markerWithPosition:self.checkInLocation.coordinate];
    self.checkInMarker.iconView = [MarkerIcon markerViewWithLabelText:NSLocalizedString(@"You", @"Current user")
                                                        labelMaxWidth:self.view.frame.size.width / 2
                                                              pinIcon:[GMSMarker markerImageWithColor:[UIColor redColor]]];
    // checkInMarker is added to the map
    self.checkInMarker.map = self.mapView;
}

/**
 *  Method used in order to place the last check-in marker
 *  this method is used only after tapping on a guardian/guarded user
 *  and the option 'See last check-in' has been selected.
 */
- (void)placeMarkerForLastCheckIn {
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.userCheckIn.location.latitude,
                                                                 self.userCheckIn.location.longitude);
    
    self.checkInMarker = [GMSMarker markerWithPosition:location];
    self.checkInMarker.iconView = [MarkerIcon markerViewWithLabelText:self.userCheckIn.user.name
                                                        labelMaxWidth:self.view.frame.size.width / 2
                                                              pinIcon:[GMSMarker markerImageWithColor:[UIColor redColor]]];
    
    self.checkInMarker.map = self.mapView;
    
    self.mapView.camera = [GMSCameraPosition cameraWithLatitude:location.latitude longitude:location.longitude zoom:0];
    [self performSelector:@selector(zoomIn) withObject:nil afterDelay:0.5];
}

/**
 *  Method used in order to animateToZoom at a predefined
 *  zoom level.
 */
- (void)zoomIn {
    [self.mapView animateToZoom:kZoomLevel];
}
- (void)placeMarkerForFollowUser:(CLLocation*)location userName:(NSString*)userName{
    // checkInMarker is initialized
//    self.followUserMarker = [GMSMarker markerWithPosition:location.coordinate];
    
    if(self.followUserMarker == nil){
        self.followUserMarker = [GMSMarker markerWithPosition:location.coordinate];
        self.followUserMarker.iconView = [MarkerIcon markerViewWithLabelText:NSLocalizedString(userName, @"Following user")
                                                        labelMaxWidth:self.view.frame.size.width / 2
                                                              pinIcon:[GMSMarker markerImageWithColor:[UIColor redColor]]];
        // checkInMarker is added to the map
        self.followUserMarker.map = self.mapView;
    }else{
        self.followUserMarker.position = location.coordinate;
    }
    self.checkInMarker.map = nil;
    self.mapView.camera = [GMSCameraPosition cameraWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude zoom:kZoomLevel];
}
#pragma mark - UICollectionView
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return arrGuardians.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"userCell"                                                                                       forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    
    User *user = [arrGuardians objectAtIndex:index];
    
    UIImageView *imageView = [cell viewWithTag:1];

    // if user is not nil, populate IBOutlets with user info
    if (user) {
        [imageView sd_setImageWithURL:[NSURL URLWithString:user.userImage.url]
                          placeholderImage:[UIImage imageNamed:@"generic_icon"]];
    }
    
    return cell;
}
@end
