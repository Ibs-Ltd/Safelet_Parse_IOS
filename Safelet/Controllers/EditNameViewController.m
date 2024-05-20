//
//  EditNameViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/7/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EditNameViewController.h"
#import "InsetTextField.h"
#import "Utils.h"
#import "User.h"
#import "SLErrorHandlingController.h"
#import "LeftMenuTableViewController.h"
#import <AMSlideMenu/AMSlideMenuMainViewController.h>
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface EditNameViewController ()

@property (weak, nonatomic) IBOutlet InsetTextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeNameButton;

@end

@implementation EditNameViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self populateUI];
}

#pragma mark Populate UI with user info

- (void)populateUI {
    User *currentUser = [User currentUser];
    
    if ([currentUser originalName].length > 0) {
        self.nameTextField.text = [currentUser originalName];
        [self nameTextFieldDidChange:self.nameTextField];
    }
}

#pragma mark IBActions

- (IBAction)nameTextFieldDidChange:(UITextField *)textField {
    if (textField.text.length == 0) {
        self.changeNameButton.enabled = NO;
        return;
    }
    
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([[[User currentUser] originalName] isEqualToString:text]) {
        self.changeNameButton.enabled = NO;
    } else {
        self.changeNameButton.enabled = YES;
    }
}

- (IBAction)didTapChangeNameButton:(id)sender {
    [self.nameTextField resignFirstResponder];
    [self changeName];
}

#pragma mark - Parse logic

- (void)changeName {
    User *currentUser = [User currentUser];
    NSString *prevName = [currentUser originalName];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    
    currentUser.name = self.nameTextField.text;
    
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:window animated:YES];
        if (succeeded) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", nil)
                                                                                     message:NSLocalizedString(@"Name has been changed.",
                                                                                                               @"Name change success")
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     [self.navigationController popViewControllerAnimated:YES];
                                                                 }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        } else {
            // recover previous data after failed "save"
            currentUser.name = prevName;
            [currentUser saveEventually];
            
            [SLErrorHandlingController handleError:error];
        }
    }];
}

@end
