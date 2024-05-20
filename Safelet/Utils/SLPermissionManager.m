//
//  SLPermissionManager.m
//  Safelet
//
//  Created by Alex Motoc on 16/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "SLPermissionManager.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@implementation SLPermissionManager

+ (void)requestMicrophonePermission {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            NSString *title = NSLocalizedString(@"Microphone permission denied", nil);
            NSString *msg = NSLocalizedString(@"In order to be fully protected, we strongly recommend that you enable microphone access", nil);
            UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
            [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
            
            [controller addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                             [[UIApplication sharedApplication] openURL:url];
                                                         }]];
            
            UIViewController *presentingVC = window.rootViewController;
            [presentingVC presentViewController:controller animated:YES completion:nil];
        }
    }];
}
@end
