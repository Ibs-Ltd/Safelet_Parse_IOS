//
//  GuardianNetworkViewController.m
//  Safelet
//
//  Created by Mihai Eros on 11/9/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "GuardianNetworkViewController.h"
#import "User.h"
#import "Utils.h"
#import "SLErrorHandlingController.h"
#import "SlideMenuMainViewController.h"
#import "LeftMenuTableViewController.h"
#import "SLDataManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface GuardianNetworkViewController ()

@property (weak, nonatomic) IBOutlet UIView *joinNetworkView;
@property (weak, nonatomic) IBOutlet UIView *leaveNetworkView;
@property (weak, nonatomic) IBOutlet UIButton *leaveNetworkButton;
@property (weak, nonatomic) IBOutlet UIButton *joinNetworkButton;
@property (weak, nonatomic) IBOutlet UIButton *btnSkip;

@end

@implementation GuardianNetworkViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self populateUI];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if([[defaults valueForKey:@"isFirstTimeLogin"] intValue] == 1){
        _btnSkip.hidden = false;
    }else{
        _btnSkip.hidden = true;
    }
    
}

#pragma mark - Configure UI

- (void)populateUI {
    if ([User currentUser].isCommunityMember) {
        self.joinNetworkView.hidden = YES;
        self.leaveNetworkView.hidden = NO;
    } else {
        self.joinNetworkView.hidden = NO;
        self.leaveNetworkView.hidden = YES;
    }
}

#pragma mark - IBActions

- (IBAction)didTapGuardianNetworkButton:(UIButton *)sender {
    BOOL isCommunityGuardian = NO;
    NSString *successMessage = NSLocalizedString(@"You have successfully left Safelet Guardian Network",
                                                 @"Leave Guardian Network with succes");
    
    if ([sender isEqual:self.joinNetworkButton]) {
        isCommunityGuardian = YES;
        successMessage = NSLocalizedString(@"You have successfully joined Safelet Guardian Network",
                                           @"Join Guardian Network with succes");
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[SLDataManager sharedManager] setUserIsCommunityGuardian:isCommunityGuardian
                                                   completion:^(BOOL success, NSError * _Nonnull error) {
                                                       [hud hideAnimated:YES];
                                                       if (error) {
                                                           [SLErrorHandlingController handleError:error];
                                                           return;
                                                       }
                                                       
                                                       [self populateUI];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        if([[defaults valueForKey:@"isFirstTimeLogin"] intValue] == 1){
            [defaults setObject:@"0" forKey:@"isFirstTimeLogin"];
            [defaults synchronize];
            
            [self performSegueWithIdentifier:@"homeSegue" sender:nil];
        }
        [UIAlertController showSuccessAlertWithMessage:successMessage];
                                                   }];
}
- (IBAction)btnSkipPress:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"0" forKey:@"isFirstTimeLogin"];
    [defaults synchronize];
    [self performSegueWithIdentifier:@"homeSegue" sender:nil];
}

@end
