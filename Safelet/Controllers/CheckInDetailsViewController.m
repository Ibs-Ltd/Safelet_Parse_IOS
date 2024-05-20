//
//  CheckInDetailsViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/29/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CheckInDetailsViewController.h"
#import "CheckIn.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CheckInDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;

@end

static NSString * const kCheckInDetailsViewControllerIdentifier = @"checkInDetailsViewController";

@implementation CheckInDetailsViewController

+ (instancetype)createDetailsCheckIn:(CheckIn *)checkIn {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CheckInDetailsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:kCheckInDetailsViewControllerIdentifier];
    vc.checkIn = checkIn;
    
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:self.checkIn.user.userImage.url]
                                          placeholderImage:[UIImage imageNamed:@"generic_icon"]];
    
    self.locationNameLabel.textColor = [UIColor appThemeColor];
    self.locationNameLabel.text = self.checkIn.locationName;
    self.messageTextView.text = self.checkIn.message;
}

@end
