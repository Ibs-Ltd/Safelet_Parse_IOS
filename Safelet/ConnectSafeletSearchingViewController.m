//
//  ConnectSafeletSearchingViewController.m
//  Safelet
//
//  Created by Alex Motoc on 25/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "ConnectSafeletSearchingViewController.h"
#import "SafeletUnitManager.h"
#import "SLErrorHandlingController.h"
#import "SafeletBLEService.h"
#import "ConnectSafeletFinishedViewController.h"
#import "BluetoothConnectionErrorViewController.h"
#import "SLError.h"
#import "User.h"

@interface ConnectSafeletSearchingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *scanningLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) SafeletUnit *connectingSafelet;
@end

@implementation ConnectSafeletSearchingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setbackgroundImageEnabled:NO];
    
    SafeletUnitManager *service = [SafeletUnitManager shared];
    [service connectNewSafeletWithCompletionBlock:^(SafeletUnit *safelet, NSError *error) {
        if (error) {
            [self handleConnectionError:error forSafelet:safelet];
            return;
        }
        
        [self setUserHasSafelet];
        
        self.connectingSafelet = safelet;
        self.descriptionLabel.text = NSLocalizedString(@"The Safelet was found. Your mobile phone is now creating a relation with the Safelet.", nil);
        self.imageView.hidden = YES;
        [self setbackgroundImageEnabled:YES];
        
        self.scanningLabel.hidden = YES;
        [self.activityIndicator stopAnimating];
        
        [safelet discoverSafeletServicesWithCompletion:^(SafeletUnit *safelet, NSError *error) {
            if (error) {
                [self handleConnectionError:error forSafelet:safelet];
                return;
            }
            
            [service createRelationForSafelet:safelet completion:^(SafeletUnit *safelet, NSError *error) {
                if (error) {
                    [self handleConnectionError:error forSafelet:safelet];
                    return;
                }
                
                NSString *identifier = [ConnectSafeletFinishedViewController storyboardID];
                UIViewController *addEmergencyPhoneVC = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
                [self.navigationController pushViewController:addEmergencyPhoneVC animated:YES];
            }];
        }];
    }];
}

- (IBAction)didTapCancelButton:(id)sender {
    SafeletUnitManager *service = [SafeletUnitManager shared];
    [service removeRelationForDisconnectedCurrentDevice];
    
    if (service.isScanning) {
        [service stopScan];
    }
    
    if (self.connectingSafelet) {
        [self.connectingSafelet cancelConnection];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

- (void)handleConnectionError:(NSError *)error forSafelet:(SafeletUnit *)safelet {
    [safelet cancelConnection];
    [safelet disconnect];
    if (safelet.central.isScanning) {
        [safelet.central stopScan];
    }
    
    NSLog(@"BLUETOOTH CONNECTION ERROR WITH SAFELET");
    
    SafeletUnitManager *service = (SafeletUnitManager *)safelet.central;
    [service removeRelationForDisconnectedCurrentDevice];
    
    NSString *storyboardID = [BluetoothConnectionErrorViewController storyboardID];
    BluetoothConnectionErrorViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:storyboardID];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)setUserHasSafelet {
    [User currentUser].hasBracelet = YES;
    [[User currentUser] saveInBackground];
}

@end
