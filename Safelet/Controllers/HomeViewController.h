//
//  HomeViewController.h
//  Safelet
//
//  Created by Ram on 18/01/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//
#import "BannerEnabledViewController.h"
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : BannerEnabledViewController<GMSMapViewDelegate, CLLocationManagerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *checkInMarker;
@property (strong, nonatomic) GMSMarker *followUserMarker;
@property (weak, nonatomic) IBOutlet UIView *viewGuardiansList;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewGuardians;
@property (weak, nonatomic) IBOutlet UIButton *btnSOS;
@property (weak, nonatomic) IBOutlet UIView *viewFollowingUser;
@property (weak, nonatomic) IBOutlet UIImageView *imgUserFollowing;
@property (weak, nonatomic) IBOutlet UILabel *lblNameUserFollowing;
@property (weak, nonatomic) IBOutlet UILabel *lblAddressUserFollowing;

@property (strong, nonatomic) NSString *currentFollowObjectId;
@property (strong, nonatomic) NSString *currentUserFollowObjectId;
@property (weak, nonatomic) IBOutlet UIView *viewPolicy;
@property (weak, nonatomic) IBOutlet WKWebView *webKitPolicy;
@property (nonatomic) BOOL isShowPolicyView;

- (IBAction)btnAcceptPolicy:(id)sender;


- (IBAction)btnSOSPress:(id)sender;
- (IBAction)btnFollowMePress:(id)sender;
- (IBAction)btnIMHerePress:(id)sender;
- (IBAction)btnStopFollowMePress:(id)sender;
- (IBAction)btnStopFollowingUserPress:(id)sender;

@end

NS_ASSUME_NONNULL_END
