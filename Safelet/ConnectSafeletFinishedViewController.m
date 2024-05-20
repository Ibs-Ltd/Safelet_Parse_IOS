//
//  ConnectSafeletFinishedViewController.m
//  Safelet
//
//  Created by Alex Motoc on 03/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "ConnectSafeletFinishedViewController.h"

@interface ConnectSafeletFinishedViewController ()

@end

@implementation ConnectSafeletFinishedViewController

+ (NSString *)storyboardID {
    return @"connectFinished";
}

- (IBAction)didTapOk:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
