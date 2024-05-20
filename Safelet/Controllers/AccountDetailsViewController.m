//
//  CreateAccountDetailInfoViewController.m
//  Safelet
//
//  Created by Mihai Eros on 9/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "AccountDetailsViewController.h"
#import "Utils.h"
#import "CommunityMemberViewController.h"
#import "CountryCodeTableViewController.h"
#import "CountryCode.h"
#import "SLPushNotificationManager.h"
#import "SLErrorHandlingController.h"
#import "SLLocationManager.h"
#import "SLDataManager.h"
#import "AppRoutinesManager.h"
#import <MBProgressHUD/MBProgressHUD.h>

@import libPhoneNumber_iOS;

static NSString * const kGoToCommunityMemberSegueIdentifier = @"communityMember";
static NSString * const kGoToCountryCodeSegueIdentifier = @"registerCountryCode";

@interface AccountDetailsViewController () <CountryCodeDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *prefixNumberButton;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (strong, nonatomic) NSString *countryCodeNumber; // example: '+40'
@end

@implementation AccountDetailsViewController

#pragma mark - ViewController Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self populateUI];
}

#pragma mark - Configure UI

- (void)populateUI {
    if (self.countryCodeNumber) {
        [self.prefixNumberButton setTitle:self.countryCodeNumber forState:UIControlStateNormal];
    }
}

#pragma mark - CountryCodeDelegate

/**
 *  CountryCodeDelegate didSelectCountryCode method
 *  some country codes are missing from libPhoneNumbers
 *  in order to have all of them we have the getMissingCountryCodes
 *  in CountryCode class.
 *  @param countryCode NSString that describes the country code
 */

- (void)didSelectCountryCode:(NSString *)countryCode {
    self.countryCodeNumber = countryCode;
    [self.prefixNumberButton setTitle:countryCode forState:UIControlStateNormal];
    [self.prefixNumberButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

#pragma mark - IBActions

- (IBAction)didTapUploadPicture:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose an option:", @"action sheet options")
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Camera", @"action sheet Camera option")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                                                                 [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                                                                 picker.allowsEditing = YES;
                                                                 
                                                                 [self presentViewController:picker animated:YES completion:nil];
                                                             }
                                                         }];
    UIAlertAction *photosAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Photos", @"action sheet Photos option")
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action) {
                                                             if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                                                                 [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                                                                 picker.allowsEditing = YES;
                                                                 
                                                                 [self presentViewController:picker animated:YES completion:nil];
                                                             }
                                                         }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"action sheet Cancel button")
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertViewController addAction:cameraAction];
    [alertViewController addAction:photosAction];
    [alertViewController addAction:cancelAction];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (IBAction)didTapBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.userImageView.image = chosenImage;
    
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
//    self.user.userImage = [PFFile fileWithName:@"image.png"
//                                          data:imageData];
    self.user.userImage = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    [self.view endEditing:YES]; // hide keyboard
    
    if ([identifier isEqualToString:kGoToCommunityMemberSegueIdentifier]) {
        // validate name and phone number before presenting the next view controller
        if ([self.nameTextField.text isEqualToString:@""]) {
            [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Name field required",
                                                                     @"Register account no name")];
            return NO;
        } else if ([self.phoneNumberTextField.text isEqualToString:@""]) {
            [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Phone number field required",
                                                                     @"Register account no phone number")];
            return NO;
        } else if ([self.prefixNumberButton.currentTitle isEqualToString:@"+ Prefix"]) {
            [UIAlertController showErrorAlertWithMessage:NSLocalizedString(@"Please select a country code",
                                                                     @"Register account no prefix number")];
            return NO;
        }
        
        // if validation successful, sign up the user
        
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [MBProgressHUD showHUDAddedTo:window animated:YES];
        
        // add the additional data to the user instance and pass the user object forward
        // the sign up will be done when all the data was provided
        
        self.user.name = self.nameTextField.text;
        self.user.phoneNumber = self.phoneNumberTextField.text;
        self.user.phoneCountryCode = self.countryCodeNumber;
        
        void (^compleionBlock)(BOOL, NSError *) = ^void(BOOL succeeded, NSError * _Nullable error) {
            [MBProgressHUD hideHUDForView:window animated:YES];
            
            if (error) {
                [SLErrorHandlingController handleError:error];
            } else {
                [AppRoutinesManager startSafeletRoutinesForUser:self.user];
                
                // go to the next screen
                [self performSegueWithIdentifier:identifier sender:nil];
            }
        };
        
        if (![User currentUser]) { // no user created => create user (by sign up)
            [self.user signUpInBackgroundWithBlock:compleionBlock];
        } else {
            [self.user saveInBackgroundWithBlock:compleionBlock];
        }
        
        return NO;
    }
    
    // for other segue identifiers, just perform them
    return YES;
}

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
