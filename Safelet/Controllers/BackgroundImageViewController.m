//
//  BackgroundImageViewController.m
//  Safelet
//
//  Created by Alex Motoc on 09/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BackgroundImageViewController.h"

@interface BackgroundImageViewController ()
@property (strong, nonatomic) UIImageView *bgImageView;
@end

@implementation BackgroundImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *img = [UIImage imageNamed:@"butterfly"];
    self.bgImageView = [[UIImageView alloc] initWithImage:img];
    self.bgImageView.alpha = 0.1f;
    self.bgImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect rect = self.bgImageView.frame;
    rect.size.width = self.view.frame.size.width;
    self.bgImageView.frame = rect;
    
    self.bgImageView.center = self.view.center;
    
    [self.view insertSubview:self.bgImageView atIndex:0];
}

- (void)setbackgroundImageEnabled:(BOOL)enabled {
    if (enabled) {
        self.bgImageView.hidden = NO;
        return;
    }
    
    self.bgImageView.hidden = YES;
}

@end
