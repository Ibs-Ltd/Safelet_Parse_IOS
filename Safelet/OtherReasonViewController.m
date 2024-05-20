//
//  OtherReasonViewController.m
//  Safelet
//
//  Created by Alex Motoc on 09/01/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "OtherReasonViewController.h"

@interface OtherReasonViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewContainerHeight;

@end

@implementation OtherReasonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGSize result = [[UIScreen mainScreen] bounds].size;
    if (result.height == 480) { // 4s
        self.textViewContainerHeight.constant -= 100;
    }
    
    if (result.height == 568) { // iPhone 5
        self.textViewContainerHeight.constant -= 30;
    }
    
    self.titleLabel.text = NSLocalizedString(@"Enter description", nil);
    [self.textView becomeFirstResponder];
    [self textViewDidChange:self.textView];
}

#pragma mark - Logic

- (IBAction)didTapExternalButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.dismissCompletionBlock) {
            self.dismissCompletionBlock(nil);
        }
    }];
}

- (IBAction)didTapSubmitButton:(id)sender {
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.dismissCompletionBlock) {
            self.dismissCompletionBlock([self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
        }
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length > 0) {
        [self enableSubmitButton];
    } else {
        [self disableSubmitButton];
    }
}

#pragma mark - Utils

- (void)enableSubmitButton {
    self.submitButton.backgroundColor = self.submitButton.tintColor;
    self.submitButton.enabled = YES;
}

- (void)disableSubmitButton {
    self.submitButton.backgroundColor = [UIColor darkGrayColor];
    self.submitButton.enabled = NO;
}

@end
