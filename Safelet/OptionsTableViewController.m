//
//  OptionsTableViewController.m
//  Safelet
//
//  Created by Alex Motoc on 26/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "OptionsTableViewController.h"
#import "SafeletUnitManager.h"
#import "Utils.h"
#import "SLErrorHandlingController.h"
#import "Firmware+Requests.h"
#import "UIAlertController+Global.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface OptionsTableViewController ()

@end

@implementation OptionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Options", nil);
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section > 0) {
        return;
    }
    
    if (indexPath.row == 0) {
        return;
    }
    
    if ([SafeletUnitManager shared].safeletPeripheral.isConnected == NO) {
        [UIAlertController showAlertWithMessage:NSLocalizedString(@"No connected Safelet found. Please connect your Safelet first", nil)];
        return;
    }
    
    [self handleFirmwareUpdateAction];
}

#pragma mark - UITableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section != 1) {
        return [super tableView:tableView titleForHeaderInSection:section];
    }
    
    // section 1 is the "Version" section; must populate with current version
    
    NSString *version = NSLocalizedString(@"Version", nil);
    NSString *releaseVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    return [NSString stringWithFormat:@"%@ %@ (%@)", version, releaseVersion, buildVersion];
}

#pragma mark - Navigation

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([SafeletUnitManager shared].safeletPeripheral.isConnected == YES) {
        return YES;
    }
    [UIAlertController showAlertWithMessage:NSLocalizedString(@"No connected Safelet found. Please connect your Safelet first", nil)];
    return NO;
}

#pragma mark - Firmware Update

- (void)installFirmwareUpdate:(Firmware *)newFirmware {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
    SafeletUnitManager *manager = [SafeletUnitManager shared];
    [manager updateConnectedSafeletWithNewFirmware:newFirmware
                                          progress:^(float progress, FirmwareUpdateProgressType progressType) {
                                              switch (progressType) {
                                                  case FirmwareUpdateProgressTypeInstalling:
                                                      hud.mode = MBProgressHUDModeDeterminate;
                                                      hud.label.text = NSLocalizedString(@"Installing...", nil);
                                                      hud.progress = progress;
                                                      break;
                                                  case FirmwareUpdateProgressTypeDownloading:
                                                      hud.mode = MBProgressHUDModeDeterminate;
                                                      hud.label.text = NSLocalizedString(@"Downloading...", nil);
                                                      hud.progress = progress;
                                                      break;
                                                  case FirmwareUpdateProgressTypeResetting:
                                                      hud.mode = MBProgressHUDModeIndeterminate;
                                                      hud.label.text = NSLocalizedString(@"Resetting...", nil);
                                                      break;
                                                  default:
                                                      break;
                                              }
                                          } completion:^(NSError *error) {
                                              [hud hideAnimated:YES];
                                              
                                              if (error) {
                                                  [SLErrorHandlingController handleError:error];
                                              } else {
                                                  NSString *msg = NSLocalizedString(@"Safelet firmware updated successfully", nil);
                                                  [UIAlertController showSuccessAlertWithMessage:msg];
                                              }
                                          }];
}

- (void)fetchLatestFirmware {
    SafeletUnit *safelet = [SafeletUnitManager shared].safeletPeripheral;
    [Firmware getLatestFirmwareForDeviceInfo:safelet.deviceInfo
                                  completion:^(Firmware *firmware, NSError *error) {
                                      if (error) {
                                          [SLErrorHandlingController handleError:error];
                                          return;
                                      } else if (firmware == nil) {
                                          NSString *msg = NSLocalizedString(@"The Safelet's firmware version is already the latest", nil);
                                          [UIAlertController showAlertWithMessage:msg];
                                          return;
                                      }
                                      [self executeUpdateFirmwareIfApproved:firmware];
                                  }];
}

- (void)executeUpdateFirmwareIfApproved:(Firmware *)newFirmware {
    NSString *firmwareDesc = [NSString stringWithFormat:@"\n%@", newFirmware.description];
    NSString *format = NSLocalizedString(@"New firmware found: %@. Are you sure you want to install now?", nil);
    NSString *msg = [NSString stringWithFormat:format, firmwareDesc];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Safelet Firmware Update", nil)
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                              style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Install", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self installFirmwareUpdate:newFirmware];
                                            }]];
    [alert show:YES];
}

- (void)handleFirmwareUpdateAction {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Search for new firmware?", nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                              style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Install", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [self fetchLatestFirmware];
                                            }]];
    [alert show:YES];
}

@end
