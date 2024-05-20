//
//  ForgotPasswordViewController.m
//  Safelet
//
//  Created by Mihai Eros on 9/28/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "EditPasswordViewController.h"
#import "InsetTextField.h"
#import "User.h"
#import "Utils.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ForgotPasswordViewController ()

@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIImageView *backArrowImageView;
@property (weak, nonatomic) IBOutlet InsetTextField *emailTextField;

@end

@implementation ForgotPasswordViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // numberOfVCs stores the number of navController's view controllers
    NSInteger numberOfVCs = self.navigationController.viewControllers.count;
    // backVC is the index number of the previous view controller
    NSInteger backVC = numberOfVCs - 2;
    
    // check if the previous view controller was an EditPasswordVC one
    if ([self.navigationController.viewControllers[backVC] isKindOfClass:[EditPasswordViewController class]]) {
        self.loginButton.hidden = YES;
        self.backArrowImageView.hidden = YES;
    } else {
        self.loginButton.hidden = NO;
        self.backArrowImageView.hidden = NO;
    }
}

#pragma mark - IBActions

- (IBAction)didTapLoginButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTapResetPasswordButton:(id)sender {
    NSString *email = [self.emailTextField.text lowercaseString];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    [User requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:window animated:YES];
        
        if (succeeded) {
            [UIAlertController showSuccessAlertWithMessage:NSLocalizedString(@"You have requested a new password. Please check your e-mail!",
                                                                       @"password recover success")];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [UIAlertController showErrorAlertWithMessage:error.localizedDescription];
        }
    }];
}

@end
