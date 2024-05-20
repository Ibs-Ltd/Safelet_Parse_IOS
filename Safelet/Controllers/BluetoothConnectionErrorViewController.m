//
//  BluetoothConnectionErrorViewController.m
//  Safelet
//
//  Created by Alex Motoc on 21/06/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BluetoothConnectionErrorViewController.h"
#import "MarkBluetoothConnectionFailed.h"

@interface BluetoothConnectionErrorViewController ()
@end

@implementation BluetoothConnectionErrorViewController

+ (NSString *)storyboardID {
    return @"BluetoothConnectionErrorViewController";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MarkBluetoothConnectionFailed request] runRequest];
}

- (IBAction)didTapDismissButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
