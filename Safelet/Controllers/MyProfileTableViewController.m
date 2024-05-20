//
//  MyProfileTableViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/6/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "MyProfileTableViewController.h"
#import "User.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "User+Logout.h"
#import "SLNotificationCenterNotifications.h"

@interface MyProfileTableViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailCellLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneCellLabel;

@property (weak, nonatomic) IBOutlet UIView *userImageContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImageView;

@property (weak, nonatomic) IBOutlet UIImageView *communityCheckMarkImageView;

@end

@implementation MyProfileTableViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new]; // don't show extra separator lines
    self.userImageContainerView.backgroundColor = [UIColor bigTableCellColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self populateWithUserData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView flashScrollIndicators];
}

#pragma mark - Populate with user info

- (void)populateWithUserData {
    User *currentUser = [User currentUser];
    self.usernameLabel.text = [currentUser originalName];
    self.nameCellLabel.text = [currentUser originalName];
    self.emailCellLabel.text = (currentUser.email) ? currentUser.email : currentUser.username;
    
    NSString *phoneNumberNoCountry = [currentUser.phoneNumber stringByReplacingOccurrencesOfString:currentUser.phoneCountryCode
                                                                                        withString:@""];
    self.phoneCellLabel.text = [currentUser.phoneCountryCode stringByAppendingFormat:@" %@", phoneNumberNoCountry];
    
    if (currentUser.userImage) {
        [self.userProfileImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.userImage.url]
                                     placeholderImage:[UIImage imageNamed:@"generic_icon"]];
    }
    
    if (currentUser.isCommunityMember) {
        self.communityCheckMarkImageView.hidden = NO;
    } else {
        self.communityCheckMarkImageView.hidden = YES;
    }
}

#pragma mark - IBActions

- (IBAction)didTapButtonChangePhoto:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Choose an option:", nil)
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [self createAlertActionForImagePickerWithTitle:NSLocalizedString(@"Camera", nil)
                                                                      withPicker:picker
                                                                      sourceType:UIImagePickerControllerSourceTypeCamera];
    UIAlertAction *photosAction = [self createAlertActionForImagePickerWithTitle:NSLocalizedString(@"Photos", nil)
                                                                      withPicker:picker
                                                                      sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil)
                                                           style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          [self deletePhoto];
                                                          
                                                          
                                                      }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    [alertViewController addAction:cameraAction];
    [alertViewController addAction:photosAction];
    [alertViewController addAction:deleteAction];
    [alertViewController addAction:cancelAction];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (IBAction)didTaponDeleteAccountButton:(id)sender {
    UIAlertController *alertViewController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Alert", nil)
                                                                                 message:NSLocalizedString(@"Delete account message", nil)
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil)
                                                           style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          [self deleteAccount];
                                                          
                                                          
                                                      }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];

    [alertViewController addAction:yesAction];
    [alertViewController addAction:cancelAction];
    
    [self presentViewController:alertViewController animated:YES completion:nil];
}
#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];
    
//    PFFile *imageFile = [PFFile fileWithName:@"image.png" data:imageData];
    PFFileObject *imageFile = [PFFileObject fileObjectWithName:@"image.png" data:imageData];
    User *currentUser = [User currentUser];
    currentUser.userImage = imageFile;
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:window animated:YES];
        
        // set user image like this such that it is cached
        [self.userProfileImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.userImage.url]
                                     placeholderImage:chosenImage]; // show chosen image as placeholder such that you don't see the transition
        
        [[NSNotificationCenter defaultCenter] postNotificationName:SLUserProfileNotification
                                                            object:nil
                                                          userInfo:nil];
        
        [picker dismissViewControllerAnimated:YES completion:NULL];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

- (UIAlertAction *)createAlertActionForImagePickerWithTitle:(NSString *)title
                                                 withPicker:(UIImagePickerController *)picker
                                                 sourceType:(UIImagePickerControllerSourceType)sourceType {
    UIAlertAction *action = [UIAlertAction actionWithTitle:title
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action) {
                                                       if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
                                                           [picker setSourceType:sourceType];
                                                           picker.allowsEditing = YES;
                                                           
                                                           [self presentViewController:picker animated:YES completion:nil];
                                                       }
                                                   }];
    return action;
}
- (void)deleteAccount {
    User *currentUser = [User currentUser];
//    NSString *objectId = [currentUser objectId];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [MBProgressHUD showHUDAddedTo:window animated:YES];

    [currentUser deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [MBProgressHUD hideHUDForView:window animated:YES];
        
        if(succeeded){
            [User logoutAndShowLoginScreen]; // logout and show login screen
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", nil)                                                                                     message:NSLocalizedString(@"Account deleted.",nil)                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                                     
                                                                 }];
            [alertController addAction:cancelAction];
            [self presentViewController:alertController animated:YES completion:nil];
        }else{
            
        }
    }];
    
}
- (void)deletePhoto {
    User *currentUser = [User currentUser];
    currentUser.userImage = nil;
    [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        [self.userProfileImageView setImage:[UIImage imageNamed:@"generic_icon"]];
    }];
    
}
@end
