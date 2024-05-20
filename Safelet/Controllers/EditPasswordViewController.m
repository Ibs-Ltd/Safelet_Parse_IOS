//
//  EditPasswordViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/7/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EditPasswordViewController.h"
#import "InsetTextField.h"
#import "Utils.h"
#import "User.h"
#import "User+Logout.h"
#import "LoginViewController.h"
#import "SLAlarmManager.h"
#import "SLLocationManager.h"
#import "SlideMenuMainViewController.h"
#import "SLErrorHandlingController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface EditPasswordViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet InsetTextField *currentPasswordTextField;
@property (weak, nonatomic) IBOutlet InsetTextField *newestPasswordTextField;
@property (weak, nonatomic) IBOutlet InsetTextField *repeatNewPasswordTextField;

@end

@implementation EditPasswordViewController

#pragma mark - IBActions

- (IBAction)didTapChangePasswordButton:(id)sender {
    [self.view endEditing:YES];
    [self changePassword];
}

// for the next/done actions on keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

#pragma mark - Logic

- (BOOL)credentialsAreValid {
    // validate email and password data before presenting the next view controller
    if ([self.newestPasswordTextField.text isEqualToString:@""]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Password field required", nil)];
        return NO;
    } else if ([self.repeatNewPasswordTextField.text isEqualToString:@""]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Repeat password required", nil)];
        return NO;
    } else if (![self.newestPasswordTextField.text isEqualToString:self.repeatNewPasswordTextField.text]) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Passwords do not match", nil)];
        return NO;
    } else if (self.newestPasswordTextField.text.length < 5) {
        [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Password must be at least 5 characters", nil)];
        return NO;
    }
    
    return YES;
}

- (void)changePassword {
    if (![self credentialsAreValid]) {
        return; // if credentials for the new password are not valid, do nothing
    }
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    // log in to check if the provided current password is correct
    [User logInWithUsernameInBackground:[User currentUser].username
                               password:self.currentPasswordTextField.text
                                  block:^(PFUser * _Nullable user, NSError * _Nullable error) {
                                      if (error) { // current password is invalid
                                          [MBProgressHUD hideHUDForView:window animated:YES];
                                          [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Current password is invalid", nil)];
                                      } else { // current password is ok, so we can change passwords
                                          if ([self.currentPasswordTextField.text isEqualToString:self.newestPasswordTextField.text]) {
                                              [MBProgressHUD hideHUDForView:window animated:YES];
                                              [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"The new password must be different from the old one", nil)];
                                              return;
                                          }
                                          
                                          user.password = self.newestPasswordTextField.text;
                                          [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                              [MBProgressHUD hideHUDForView:window animated:YES];
                                              
                                              if (succeeded) { // upon success the session expires, so we need to logout the user and present the login screen
                                                  NSString *alertMsg = NSLocalizedString(@"Password changed successfully. Please log back in using the new password", nil);
                                                  [UIAlertController showSuccessAlertWithMessage:alertMsg];
                                                  
                                                  [User logoutAndShowLoginScreen];
                                              } else {
                                                  [SLErrorHandlingController handleError:error];
                                              }
                                          }];
                                      }
                                  }];
}

@end
