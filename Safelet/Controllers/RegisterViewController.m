//
//  RegisterViewController.m
//  Safelet
//
//  Created by Mihai Eros on 9/28/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "RegisterViewController.h"
#import "Utils.h"
#import "AccountDetailsViewController.h"
#import "User.h"
#import "User+Requests.h"
#import "SLErrorHandlingController.h"
#import <SafariServices/SafariServices.h>

static NSString * const kStoryboardID = @"RegisterViewControllerID";
static NSString * const kTermConditionURL = @"https://safelet.com/terms-of-service/";

@interface RegisterViewController ()
@property (strong, nonatomic) User *user;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnTermsCondition;

@end

@implementation RegisterViewController

+ (NSString *)storyboardID {
    return kStoryboardID;
}

#pragma mark - IBActions

- (IBAction)didTapLoginButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)btnTermsConditionPress:(id)sender {
    if(_btnTermsCondition.isSelected){
        _btnTermsCondition.selected = false;
    }else{
        _btnTermsCondition.selected = true;
    }
}
- (IBAction)btnTermsConditionLinkPress:(id)sender {
    NSURL *url = [NSURL URLWithString:kTermConditionURL];
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
    [self.navigationController presentViewController:safari animated:YES completion:nil];
    
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    [self.view endEditing:YES]; // hide keyboard
    
    // validate email and password data before presenting the next view controller
    if ([self.emailTextField.text isEqualToString:@""]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Email field required",
                                                                 @"Register account no email")];
        return NO;
    } else if (![self.emailTextField.text isValidEmailFormat]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Invalid email address",
                                                                 @"Register account invalid email")];
        return NO;
    } else if ([self.passwordTextField.text isEqualToString:@""]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Password field required",
                                                                 @"Register account no password")];
        return NO;
    } else if ([self.repeatPasswordTextField.text isEqualToString:@""]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Repeat password required",
                                                                 @"Register account no repeat password")];
        return NO;
    } else if (![self.passwordTextField.text isEqualToString:self.repeatPasswordTextField.text]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Passwords do not match",
                                                                 @"Register account passwords don't match")];
        return NO;
    } else if (self.passwordTextField.text.length < 5) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Password must be at least 5 characters",
                                                                 @"Register account password too short")];
        return NO;
    }else if(!_btnTermsCondition.isSelected){
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Please accept terms and conditions",
                                                                 @"Register account terms condition")];
        return NO;
    }
    
    // create a user instance with the data that was provided so far (email and password)
    self.user = [User object];
    self.user.email = [self.emailTextField.text lowercaseString];
    self.user.username = self.user.email;
    self.user.password = self.passwordTextField.text;
    self.user.isTermsConditionAccepted = true;
    
    [self.user checkIfUserExistsWithCompletion:^(BOOL exists, NSError * _Nullable error) {
        if (exists) { // another user with same username exists
            [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"User with same email already exists",
                                                                     @"Register account duplicate email")];
        } else if (error) { // we found an error
            [SLErrorHandlingController handleError:error];
        } else { // the user doesn't exist, so we can continue with the register process
            [self performSegueWithIdentifier:identifier sender:nil];
        }
    }];
    
    return NO; // always return NO, because we manually perform the segue after all validations
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // pass the user object to the next view controller to get the additional required data
    // the sign up will be done when all the data was provided
    
    AccountDetailsViewController *destVC = segue.destinationViewController;
    destVC.user = self.user;
}

@end
