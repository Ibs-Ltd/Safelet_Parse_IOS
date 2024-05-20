//
//  CreateAccountCommunityMemberViewController.m
//  Safelet
//
//  Created by Mihai Eros on 9/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CommunityMemberViewController.h"
#import "Utils.h"
#import "SLErrorHandlingController.h"
#import <MBProgressHUD/MBProgressHUD.h>

static NSString * const kAcceptedCommunitySegueIdentifier = @"acceptedCommunityMember";

@interface CommunityMemberViewController ()
@end

@implementation CommunityMemberViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:kAcceptedCommunitySegueIdentifier]) {
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [MBProgressHUD showHUDAddedTo:window animated:YES];
        
        
        User *user = [User currentUser];
        user.isCommunityMember = YES;
        
        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:window animated:YES];
            
            if (error) {
                [SLErrorHandlingController handleError:error];
            } else {
                [self performSegueWithIdentifier:identifier sender:nil];
            }
        }];
        
        return NO;
    }
    
    // if rejected community member simply go to the next screen, since user.isCommunityMember = NO by default
    return YES;
}

@end
