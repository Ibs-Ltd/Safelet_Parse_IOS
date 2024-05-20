//
//  AlarmBannerView.m
//  Safelet
//
//  Created by Alex Motoc on 09/02/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "AlarmBannerView.h"
#import "User.h"
#import "Utils.h"
#import <SDWebImage/UIImageView+WebCache.h>
        
static CGFloat const kBannerViewHeight = 41;

@interface AlarmBannerView ()
@property (weak, nonatomic) IBOutlet UILabel *recordingLabel;
@end

@implementation AlarmBannerView

+ (AlarmBannerView *)createFromNib {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                   owner:self
                                                 options:nil];
    
    return [array firstObject]; // our view is the first one here
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor alarmBannerColor];
}

+ (CGFloat)bannerHeight {
    return kBannerViewHeight;
}

- (void)setRecordingLabelHidden:(BOOL)hidden {
    self.recordingLabel.hidden = hidden;
}

@end
