//
//  StartViewController.m
//  Safelet
//
//  Created by Alex Motoc on 09/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "StartViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import <SafariServices/SafariServices.h>

static NSString * const kPrivacyURL = @"http://safelet.com/us/privacy-policy/";

@interface StartViewController ()

@end

@implementation StartViewController

- (IBAction)didTapRegister:(id)sender {
    LoginViewController *loginVC = [self.storyboard instantiateViewControllerWithIdentifier:[LoginViewController storyboardID]];
    RegisterViewController *registerVC = [self.storyboard instantiateViewControllerWithIdentifier:[RegisterViewController storyboardID]];
    
    [self.navigationController setViewControllers:@[loginVC, registerVC] animated:YES]; 
}

- (IBAction)didTapPrivacy:(id)sender {
    NSURL *url = [NSURL URLWithString:kPrivacyURL];
    SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:url];
    [self.navigationController presentViewController:safari animated:YES completion:nil];
}

@end
