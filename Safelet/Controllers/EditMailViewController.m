//
//  EditMailViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/7/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EditMailViewController.h"
#import "InsetTextField.h"
#import "Utils.h"
#import "User.h"
#import "SLErrorHandlingController.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface EditMailViewController ()

@property (weak, nonatomic) IBOutlet InsetTextField *emailAddressTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeEmailButton;

@end

@implementation EditMailViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self populateUI];
}

#pragma Populate UI with user info

- (void)populateUI {
    User *currentUser = [User currentUser];
    
    if (currentUser.email) {
        self.emailAddressTextField.text = currentUser.email;
        [self emailTextFieldDidChange:self.emailAddressTextField];
    }else if(currentUser.username){
        self.emailAddressTextField.text = currentUser.username;
        [self emailTextFieldDidChange:self.emailAddressTextField];
    }
}

#pragma mark - IBActions

- (IBAction)emailTextFieldDidChange:(UITextField *)textField {
    if (textField.text.length == 0) {
        self.changeEmailButton.enabled = NO;
        return;
    }
    
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([[User currentUser].email isEqualToString:text]) {
        self.changeEmailButton.enabled = NO;
    } else {
        self.changeEmailButton.enabled = YES;
    }
}

- (IBAction)didTapChangeEmailButton:(id)sender {
    [self.emailAddressTextField resignFirstResponder];
    
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    //Valid email address

    if ([emailTest evaluateWithObject:self.emailAddressTextField.text] == YES)
    {
         //Do Something
        [self changeEmail];
    }
    else
    {
         NSLog(@"email not in proper format");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                                 message:NSLocalizedString(@"Email address format is invalid.",
                                                                                                           @"Email address format is invalid")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                             }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - Parse logic

- (void)changeEmail {
    User *currentUser = [User currentUser];
    NSString *prevEmail = currentUser.email;
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    currentUser.email = [self.emailAddressTextField.text lowercaseString];
    currentUser.username = currentUser.email;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:window animated:YES];
        if (succeeded) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", nil)
                                                                                     message:NSLocalizedString(@"Email address has been changed.",
                                                                                                               @"Email address change success")
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [self.navigationController popViewControllerAnimated:YES];
                                                                 }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            // recover data after failed "save"
            currentUser.email = prevEmail;
            currentUser.username = prevEmail;
            [currentUser saveEventually];
            
            [SLErrorHandlingController handleError:error];
        }
    }];
}

@end
