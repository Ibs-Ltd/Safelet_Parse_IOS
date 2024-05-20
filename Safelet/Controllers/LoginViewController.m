//
//  ViewController.m
//  Safelet
//
//  Created by Alex Motoc on 28/09/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "LoginViewController.h"
#import "User.h"
#import "Utils.h"
#import "SLAlarmManager.h"
#import "SLNavBarAppearanceManager.h"
#import "SLPushNotificationManager.h"
#import "SLErrorHandlingController.h"
#import "SLUserDefaults.h"
#import "AppRoutinesManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

static NSString * const kLoginSegueIdentifier = @"loginSegue";
static NSString * const kStoryboardID = @"LoginViewControllerID";

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@end

@implementation LoginViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set the navigation bar to default appearance; useful when logging out, to reset the navbar.
    [SLNavBarAppearanceManager setupDefaultNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // reset password text field
    self.emailTextField.text = [SLUserDefaults previouslyUsedEmail];
    self.passwordTextField.text = @"";
}

#pragma mark - Getter

+ (NSString *)storyboardID {
    return kStoryboardID;
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:kLoginSegueIdentifier]) {
        [self.view endEditing:YES]; // hide keyboard
        
        // validate email and password data before presenting the next view controller
        if ([self.emailTextField.text isEqualToString:@""]) {
            [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Email field required", nil)];
            return NO;
        } else if (![self.emailTextField.text isValidEmailFormat]) {
            [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Invalid email address", nil)];
            return NO;
        } else if ([self.passwordTextField.text isEqualToString:@""]) {
            [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Password field required", nil)];
            return NO;
        }
        
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [MBProgressHUD showHUDAddedTo:window animated:YES];
        
        [User logInWithUsernameInBackground:[self.emailTextField.text lowercaseString]
                                   password:self.passwordTextField.text
                                      block:^(PFUser * _Nullable user, NSError * _Nullable error) {
            if (error) {
                [SLErrorHandlingController handleError:error];
                [MBProgressHUD hideHUDForView:window animated:YES];
            } else {
                [AppRoutinesManager startSafeletRoutinesForUser:(User *)user];
                
                if ([User currentUser].isCommunityMember) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:@"0" forKey:@"isFirstTimeLogin"];
                    [defaults synchronize];
                    
                    // get any active alarm for this user
                    [SLAlarmManager getAlarmForUser:(User *)user
                                         completion:^(Alarm *alarm, NSError *error) {
                        if (error) {
                            [SLErrorHandlingController handleError:error];
                            // continue execution after error, since login was successful
                        }
                        
                        if (alarm) { // if there is an active alarm for the provided user, setup Alarm Mode
                            [SLAlarmManager handleDispatchAlarm:alarm shouldPlaySound:NO];
                        } else { // no active alarm for this user, setup Normal Mode
                            [SLAlarmManager handleStopAlarm];
                        }
                        
                        [MBProgressHUD hideHUDForView:window animated:YES];
                        [self performSegueWithIdentifier:identifier sender:nil];
                    }];
                }else{
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setObject:@"1" forKey:@"isFirstTimeLogin"];
                    [defaults synchronize];
                    [self performSegueWithIdentifier:@"guardianNetwork" sender:nil];
                }
            }
        }];
        return NO;
    }
    return YES;
}

@end
