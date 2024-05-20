//
//  EditTelNumberViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/7/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EditTelNumberViewController.h"
#import "InsetTextField.h"
#import <Parse/Parse.h>
#import "Utils.h"
#import "User.h"
#import "CountryCodeTableViewController.h"
#import "CountryCode.h"
#import "SLErrorHandlingController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface EditTelNumberViewController () <CountryCodeDelegate>

@property (weak, nonatomic) IBOutlet InsetTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *prefixNumberButton;
@property (weak, nonatomic) IBOutlet UIButton *changePhoneButton;

@property (strong, nonatomic) NSString *countryCodeNumber; // example: '+40'
@property (nonatomic) BOOL dataUpdated;

@end

static NSString * const kGoToCountryCodeSegueIdentifier = @"editCountryCode";

@implementation EditTelNumberViewController

#pragma mark - ViewController Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self populateUI];
}

#pragma mark - CountryCodeDelegate

- (void)didSelectCountryCode:(NSString *)countryCode {
    self.countryCodeNumber = countryCode;
    [self phoneTextFieldDidChange:self.phoneNumberTextField];
    [self.prefixNumberButton setTitle:countryCode forState:UIControlStateNormal];
}

#pragma Populate UI with user info

- (void)populateUI {
    User *currentUser = [User currentUser];
    
    if (currentUser.phoneCountryCode && !self.dataUpdated) {
        self.phoneNumberTextField.text = [currentUser phoneNumberWithoutCountryCode];
        self.countryCodeNumber = currentUser.phoneCountryCode;
        self.dataUpdated = YES;
        
        [self phoneTextFieldDidChange:self.phoneNumberTextField];
    }
    
    [self.prefixNumberButton setTitle:self.countryCodeNumber forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (IBAction)phoneTextFieldDidChange:(UITextField *)textField {
    if (textField.text.length == 0) {
        self.changePhoneButton.enabled = NO;
        return;
    }
    
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([[[User currentUser] phoneNumberWithoutCountryCode] isEqualToString:text] &&
        [[User currentUser].phoneCountryCode isEqualToString:self.countryCodeNumber]) {
        self.changePhoneButton.enabled = NO;
    } else {
        self.changePhoneButton.enabled = YES;
    }
}

- (IBAction)didTapChangePhoneNumberButton:(id)sender {
    [self.phoneNumberTextField resignFirstResponder];
    [self changePhoneNumber];
}

#pragma mark - Parse logic

- (void)changePhoneNumber {
    User *currentUser = [User currentUser];
    
    NSString *prevPhoneCountryCode = currentUser.phoneCountryCode;
    NSString *prevPhoneNumber = currentUser.phoneNumber;
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    currentUser.phoneNumber = self.phoneNumberTextField.text;
    currentUser.phoneCountryCode = self.countryCodeNumber;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:window animated:YES];
        if (succeeded) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", nil)
                                                                                     message:NSLocalizedString(@"Phone number has been changed.",
                                                                                                               @"Phone number change success")
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK"
                                                                   style:UIAlertActionStyleDefault
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [self.navigationController popViewControllerAnimated:YES];
                                                                 }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            // recover data after failed "save"
            currentUser.phoneNumber = prevPhoneNumber;
            currentUser.phoneCountryCode = prevPhoneCountryCode;
            [currentUser saveEventually];
            
            [SLErrorHandlingController handleError:error];
        }
    }];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kGoToCountryCodeSegueIdentifier]) {
        UINavigationController *navigationVC = segue.destinationViewController;
        NSInteger lastViewControllerIndex = navigationVC.viewControllers.count - 2;
        
        if (lastViewControllerIndex < 0) {
            lastViewControllerIndex = 0;
        }
        
        if ([[navigationVC.viewControllers objectAtIndex:lastViewControllerIndex] isKindOfClass:[CountryCodeTableViewController class]]) {
            CountryCodeTableViewController *vc = (CountryCodeTableViewController *)[navigationVC.viewControllers objectAtIndex:lastViewControllerIndex];
            vc.delegate = self;
        }
    }
}

@end
