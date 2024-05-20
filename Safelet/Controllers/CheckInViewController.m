//
//  CheckInViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/1/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CheckInViewController.h"
#import "CheckIn.h"
#import "User+Requests.h"
#import "Utils.h"
#import "CheckInDetailsViewController.h"
#import "CheckIn.h"
#import "User.h"
#import "Utils.h"
#import "SLLocationManager.h"
#import "SLErrorHandlingController.h"
#import "MarkerIcon.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface CheckInViewController () <GMSMapViewDelegate, CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIView *checkInBottomContainerView;
@property (weak, nonatomic) IBOutlet UIView *checkInTopContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *checkedInUserProfileImageView;
@property (weak, nonatomic) IBOutlet UILabel *checkedInMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *checkedInLocationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mapViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerConstraint;

@property (strong, nonatomic) CheckIn *userCheckIn;
@property (strong, nonatomic) GMSMarker *checkInMarker;
@property (strong, nonatomic) NSString *checkInLocationName;

@property (nonatomic) CLLocation *checkInLocation;

@property (nonatomic) BOOL firstLocationUpdate;
@property (nonatomic) BOOL setupMarker;

@end

static const NSInteger kZoomLevel = 17;
static NSString * const kCheckInDetailsSegueIdentifier = @"checkInDetailsSegueIdentifier";
static NSString * const kCheckInViewControllerIdentifier = @"checkInViewControllerIdentifier";

@implementation CheckInViewController

#pragma mark - Initializers

+ (instancetype)createForUserCheckIn:(CheckIn *)checkIn {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CheckInViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kCheckInViewControllerIdentifier];
    vc.userCheckIn = checkIn;
    
    return vc;
}

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    // do this because subclass of BannerEnabledViewController
    // check the case to see if the first view in the hierarchy is the image view or the map view
    // perform this before [super viewDidLoad] because we need to have a value set for self.topConstraint
    self.topConstraint = self.mapViewTopConstraint;
    if (self.userCheckIn) {
        self.topConstraint = self.topContainerConstraint;
    }
    
    [super viewDidLoad];
    
    self.checkInLocationName = [SLLocationManager getUnavailableLocationDefaultName]; // default
    
    self.checkInMarker = [GMSMarker new];
    
    // initializations
    [self initializeMapView];
    [self initializeAccordingly];
    
    // setup for scrollView to work properly
    self.edgesForExtendedLayout = UIRectEdgeNone;

    if (self.userCheckIn) { // check if we have a check-in or not
        self.checkInBottomContainerView.hidden = YES;
        self.checkInTopContainerView.hidden = NO;
        
        self.mapViewBottomConstraint.constant -= self.checkInBottomContainerView.frame.size.height; // bottom constraint of mapView gets larger
        self.mapViewTopConstraint.constant += self.checkInTopContainerView.frame.size.height + self.topConstraint.constant; // top constraint of mapView gets smaller, because we add another view
        
        [self placeMarkerForLastCheckIn]; // places the marker animated and zooms-in for the last check-in
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.mapView.delegate = nil;
    
    // removeObserver should not be executed if there is no observer added
    if (!self.userCheckIn) {
        SLLocationManager *locationManager = [SLLocationManager sharedManager];
        [locationManager setupNormalLocationTracking];
        [locationManager removeObserver:self forKeyPath:@"currentLocation"];
        
        [self.mapView removeObserver:self forKeyPath:@"myLocation"];
    }
}

#pragma mark - Initializations

/**
 *  Method used in order to properly initialize the ViewController
 *  If we want to see the last check-in of an user it checks if check-in exists
 *  otherwise it knows that we want to check-in at current location.
 */
- (void)initializeAccordingly {
    // we check if we have a check-in & also an user
    if (self.userCheckIn) {
        [self.checkedInUserProfileImageView sd_setImageWithURL:[NSURL URLWithString:self.userCheckIn.user.userImage.url]
                                              placeholderImage:[UIImage imageNamed:@"generic_icon"]];
        NSString *location = self.userCheckIn.locationName;
        NSString *message = self.userCheckIn.message;
        
        self.checkedInMessageLabel.text = message;
        self.checkedInLocationLabel.text = location;
        self.checkedInLocationLabel.textColor = [UIColor appThemeColor];
    } else {
        // if we don't have a check-in, we want to track current location
        SLLocationManager *locationManager = [SLLocationManager sharedManager];
        [locationManager setupPreciseLocationTracking];
        [locationManager addObserver:self
                          forKeyPath:@"currentLocation"
                             options:NSKeyValueObservingOptionNew
                             context:NULL];
        
        [self handleLocationManagerKVOTrigger:locationManager]; // force initial setup
        
        // observes the changes for "myLocation" keyPath
        [self.mapView addObserver:self
                       forKeyPath:@"myLocation"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
    }
}

/**
 *  Method used in order to initalize the mapView.
 */
- (void)initializeMapView {
    self.mapView.delegate = self;
    
    // checks for check-in and if not, it enables current location and myLocationButton
    if (!self.userCheckIn) {
        self.mapView.myLocationEnabled = YES;
        self.mapView.settings.myLocationButton = YES;
    }
    
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
    [self.descriptionTextField endEditing:YES];
    
    return NO;
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    // keyboard gets dismissed
    [self.descriptionTextField endEditing:YES];
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    // keyboard gets dismissed
    [self.descriptionTextField endEditing:YES];
}

#pragma mark - IBActions

- (IBAction)didTapCheckMarkButton:(id)sender {
    // we create a PFGeoPoint which will be sent to parse later
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.checkInLocation.coordinate.latitude
                                               longitude:self.checkInLocation.coordinate.longitude];

        
    // sends the check-in geoPoint, address, message to parse
    [[User currentUser] sendCheckInWithGeoPoint:point
                                        address:self.checkInLocationName
                                        message:self.descriptionTextField.text
                                     completion:^(BOOL success, NSError * _Nullable error) {
                                         if (error) {
                                             [SLErrorHandlingController handleError:error];
                                         } else {
                                             [UIAlertController showSuccessAlertWithMessage:NSLocalizedString(@"You are checked in. Your guardians have been informed.",
                                                                                                        @"Check-in success")];
                                         }
                                     }];
    
    // keyboard gets dismissed
    [self.view endEditing:YES];
    // description text field gets cleared
    self.descriptionTextField.text = @"";
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kCheckInDetailsSegueIdentifier]) {
        
        // checkInDetailsVC's checkIn property is set
        CheckInDetailsViewController *vc = segue.destinationViewController;
        vc.checkIn = self.userCheckIn;
    }
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

@end
