//
//  SLErrorHandlingController.m
//  Safelet
//
//  Created by Alex Motoc on 20/11/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "SLErrorHandlingController.h"
#import "Utils.h"
#import "User+Logout.h"
#import "SLError.h"
#import "BluetoothConnectionErrorViewController.h"
#import "UIAlertController+Global.h"
#import <Parse/Parse.h>

@implementation SLErrorHandlingController

+ (void)handleError:(NSError *)error {
    if ([error.domain isEqualToString:PFParseErrorDomain]) {
        switch (error.code) {
            case kPFErrorInvalidSessionToken:
                [self handleInvalidSessionTokenError];
                break;
            default:
                [UIAlertController showErrorAlertWithMessage:[self getMessageForError:error]];
                break;
        }
    } else if ([error.domain isEqualToString:SLSafeletErrorDomain]) {
        switch (error.code) {
            case SLErrorCodeNoContactsPermission:
                [self handleNoContactsPermissionError];
                break;
            default:
                [UIAlertController showErrorAlertWithMessage:[self getMessageForError:error]];
                break;
        }
    } else {
        [UIAlertController showErrorAlertWithMessage:[self getMessageForError:error]];
        return;
    }
}

+ (void)handleSafeletBluetoothConnectionError {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BluetoothConnectionErrorViewController *vc = [storyboard instantiateViewControllerWithIdentifier:[BluetoothConnectionErrorViewController storyboardID]];
    
    UIViewController *currentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [currentVC presentViewController:vc animated:YES completion:nil];
}

+ (NSDictionary *)getServerErrorPayloadDictionaryFromError:(NSError *)error {
    NSDictionary *serverErrorDict;
    NSError *serializationError = nil;
    
    if ([error.localizedDescription isKindOfClass:[NSDictionary class]]) {
        serverErrorDict = (NSDictionary *)error.localizedDescription;
    } else {
        NSString *desc = [NSString stringWithFormat:@"%@",error.localizedDescription];
        serverErrorDict = [NSJSONSerialization JSONObjectWithData:[desc dataUsingEncoding:NSUTF8StringEncoding]
                                                          options:kNilOptions
                                                            error:&serializationError];
    }
    
    if (serializationError) {
        return nil;
    }
    
    return serverErrorDict;
}

#pragma mark - Private utils

#warning create a separate class to handle server formatted errors
+ (NSString *)getMessageForError:(NSError *)error {
    NSDictionary *serverErrorDict = [self getServerErrorPayloadDictionaryFromError:error];
    
    if (serverErrorDict == nil) {
        return error.localizedDescription;
    }
    
    NSString *localizedKey = serverErrorDict[@"localizedKey"];
    NSString *fullErrorMessage = serverErrorDict[@"fullErrorMessage"];
    NSArray *arguments = serverErrorDict[@"localizedArgs"];
    
    NSString *fallbackMessage = fullErrorMessage;
    if (fallbackMessage.length == 0) {
        fallbackMessage = serverErrorDict[@"message"];
    }
    
    if (fallbackMessage.length == 0) {
        return error.localizedDescription;
    }
    
    NSString *format = NSLocalizedStringWithDefaultValue(localizedKey, @"Localizable", [NSBundle mainBundle], fallbackMessage, nil);
    return [NSString stringWithFormat:format arguments:arguments];
}

+ (void)handleInvalidSessionTokenError {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Invalid Session", @"User session has expired")
                                                                   message:NSLocalizedString(@"Session is no longer valid. Please log in again.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                [User logoutAndShowLoginScreen];
                                            }]];
    [alert show:YES];
}

+ (void)handleNoContactsPermissionError {
    NSString *msg = NSLocalizedString(@"Can't retrieve contacts because the permission is denied. Please enable the Contacts permission from the Settings app", nil);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Permission denied", nil)
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Dismiss", nil)
                                              style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil)
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                                                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                [[UIApplication sharedApplication] openURL:url];
                                            }]];
    [alert show:YES];
}

@end
