//
//  ImHereViewController.m
//  Safelet
//
//  Created by Ram on 24/01/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//

#import "ImHereViewController.h"
#import "Utils.h"
#import "User+Requests.h"
#import "ConnectionCell.h"
#import "SLContactsUIManager.h"
#import "SLErrorHandlingController.h"
#import "SlideMenuMainViewController.h"
#import "SLDataManager.h"
#import "SLNotificationCenterNotifications.h"
#import "SLMenuSelectionController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "CheckIn.h"
#import "User.h"
#import "MarkerIcon.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <GoogleMaps/GoogleMaps.h>
#import <Parse/Parse.h>

@interface ImHereViewController (){
    NSMutableArray *arrSelectedUsers;
}

@property (nonatomic, assign) SLGuardianStatus state;


@end

@implementation ImHereViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    arrSelectedUsers = [[NSMutableArray alloc]init];
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.title = @"I'M HERE";
    
    if ([SLDataManager sharedManager].didLoadMyConnections == NO) {
        [self fetchConnections:nil];
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    
    return [SLDataManager sharedManager].guardianUsers.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ConnectionCell *cell = (ConnectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kcellConnectionIdentifier                                                                                       forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    
    User *user = [[SLDataManager sharedManager].guardianUsers objectAtIndex:index];
    
    [cell populateWithUser:user];
    
    NSString *objectId = user.objectId;
    if([arrSelectedUsers containsObject:objectId]){
        cell.layer.borderColor = [UIColor redColor].CGColor;
        cell.layer.borderWidth = 1.0;
    }else{
        cell.layer.borderColor = [UIColor clearColor].CGColor;
        cell.layer.borderWidth = 0.0;
    }
    
    return cell;
}

#pragma mark - UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    User *user = [[SLDataManager sharedManager].guardianUsers objectAtIndex:indexPath.row];
    NSString *objectId = user.objectId;
    
    if([arrSelectedUsers containsObject:objectId]){
        [arrSelectedUsers removeObject:objectId];
    }else{
        [arrSelectedUsers addObject:objectId];
    }
    
    [self.collectionView reloadData];
}
- (void)fetchConnections:(id)object {
    MBProgressHUD *hud = nil;
    if (object == nil) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [[SLDataManager sharedManager] fetchConnectionsWithCompletion:^(NSArray *guardians, NSArray *guarded, NSError *error) {
        [hud hideAnimated:YES];
        
        if (error) {
            [SLErrorHandlingController handleError:error];
            return;
        }else{
            for (User *user in guardians) {
                NSString *objectId = user.objectId;
                [self->arrSelectedUsers addObject:objectId];
            }
            [self.collectionView reloadData];
        }
    }];
}
- (IBAction)didTapCheckMarkButton:(id)sender {
    if(arrSelectedUsers.count == 0){
        [UIAlertController showSuccessAlertWithMessage:NSLocalizedString(@"Please select guardians.",@"Selected Check-in Warning")];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    // we create a PFGeoPoint which will be sent to parse later
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:self.checkInLocation.coordinate.latitude
                                               longitude:self.checkInLocation.coordinate.longitude];
        
    // sends the check-in geoPoint, address, message to parse
    [[User currentUser] sendCheckInWithGeoPointMultiple:point
                                                address:self.checkInLocationName
                                                message:@""
                                          selectedUsers:arrSelectedUsers
                                             completion:^(BOOL success, NSError * _Nullable error) {
                                                 
                                                 [hud hideAnimated:YES];
                                                 if (error) {
                                                     [SLErrorHandlingController handleError:error];
                                                 } else {
                                                     [UIAlertController showSuccessAlertWithMessage:NSLocalizedString(@"You are checked in. Your guardians have been informed.",
                                                                                                                      @"Check-in success")];
                                                 }
                                             }];
    
}

@end
