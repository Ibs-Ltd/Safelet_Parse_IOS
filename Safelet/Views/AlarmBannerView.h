//
//  AlarmBannerView.h
//  Safelet
//
//  Created by Alex Motoc on 09/02/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmBannerView : UIView

+ (AlarmBannerView *)createFromNib;
+ (CGFloat)bannerHeight;
- (void)setRecordingLabelHidden:(BOOL)hidden;

@end
