//
//  StopAlarmReasonViewController.m
//  Safelet
//
//  Created by Alex Motoc on 06/01/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "StopAlarmReasonViewController.h"
#import "OtherReasonViewController.h"

static NSString * const kOtherReasonSegueIdentifier = @"otherReasonSegueIdentifier";
static NSString * const kStopAlarmOptionCellIdentifier = @"stopAlarmOptionCellIdentifier";

@interface StopAlarmReasonViewController () <UITableViewDataSource, UITabBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation StopAlarmReasonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"Please select a reason:", nil);
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 60.0f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kStopAlarmOptionCellIdentifier forIndexPath:indexPath];
    
    NSString *optionTitle = @"";
    NSNumber *numberOption = self.dataSource[indexPath.row];
    if ([numberOption isEqualToNumber:@(StopReasonTestAlarm)]) {
        optionTitle = NSLocalizedString(@"Please do not worry, this was just a test alarm", nil);
    } else if ([numberOption isEqualToNumber:@(StopReasonAccidentalAlarm)]) {
        optionTitle = NSLocalizedString(@"Please do not worry, I accidentally activated the alarm", nil);
    } else if ([numberOption isEqualToNumber:@(StopReasonHelpNoLongerNeeded)]) {
        optionTitle = NSLocalizedString(@"Thanks for being alert. I do not longer need your help", nil);
    } else {
        optionTitle = NSLocalizedString(@"Other", nil);
    }
    
    cell.textLabel.text = optionTitle;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber *numberOption = self.dataSource[indexPath.row];
    
    if ([numberOption isEqualToNumber:@(StopReasonOther)]) {
        [self performSegueWithIdentifier:kOtherReasonSegueIdentifier sender:self];
    } else {
        StopReason reason = StopReasonHelpNoLongerNeeded;
        if ([numberOption isEqualToNumber:@(StopReasonTestAlarm)]) {
            reason = StopReasonTestAlarm;
        } else if ([numberOption isEqualToNumber:@(StopReasonAccidentalAlarm)]) {
            reason = StopReasonAccidentalAlarm;
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            if (self.dismissCompletionBlock) {
                self.dismissCompletionBlock(reason, nil);
            }
        }];
    }
}

#pragma mark - Navigation

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kOtherReasonSegueIdentifier]) {
        OtherReasonViewController *vc = segue.destinationViewController;
        [vc setDismissCompletionBlock:^(NSString *userDescription) {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            
            if (userDescription) {
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.dismissCompletionBlock) {
                        self.dismissCompletionBlock(StopReasonOther, userDescription);
                    }
                }];
            }
        }];
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([identifier isEqualToString:kOtherReasonSegueIdentifier]) {
        return NO;
    }
    
    return YES;
}

@end
