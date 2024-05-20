//
//  MarkerIcon.m
//  Safelet
//
//  Created by Alex Motoc on 13/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "MarkerIcon.h"
#import "Utils.h"

static CGFloat const kLabelHeightPadding = 8;
static CGFloat const kLabelWidthPadding = 30;
static CGFloat const kLabelMarginPadding = 8;
static CGFloat const kLabelPinVerticalSpacing = 12;

@implementation MarkerIcon

+ (UIImage *)markerIconWithLabelText:(NSString *)text labelMaxWidth:(CGFloat)maxWidth pinIcon:(UIImage *)pinIcon {
    UIView *view = [self markerViewWithLabelText:text labelMaxWidth:maxWidth pinIcon:pinIcon];
    return [UIImage imageWithView:view];
}

+ (UIView *)markerViewWithLabelText:(NSString *)text labelMaxWidth:(CGFloat)maxWidth pinIcon:(UIImage *)pinIcon {
    // start by creating the label
    UILabel *label = [UILabel new];
    label.text = text;
    label.backgroundColor = [UIColor whiteColor];
    [label sizeToFit];
    
    // edit the label frame
    CGRect rect = label.frame;
    rect.size.width += kLabelWidthPadding;
    if (rect.size.width > maxWidth) { // must fit into a maximum witdth
        rect.size.width = maxWidth;
    }
    
    // add some width and height padding and margins
    rect.size.height += kLabelHeightPadding;
    rect.origin.x = kLabelMarginPadding;
    rect.origin.y = kLabelMarginPadding;
    label.frame = rect;
    label.textAlignment = NSTextAlignmentCenter;
    
    // add shadow to label
    label.layer.shadowColor = [UIColor blackColor].CGColor;
    label.layer.shadowOffset = CGSizeZero;
    label.layer.shadowRadius = 3.0f;
    label.layer.shadowOpacity = 0.5f;
    label.layer.shadowPath = [UIBezierPath bezierPathWithRect:label.bounds].CGPath;
    label.layer.masksToBounds = NO;
    
    // now create the pin image view
    UIImageView *imageView = [[UIImageView alloc] initWithImage:pinIcon];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.center = label.center;
    rect = imageView.frame;
    rect.origin.y = label.frame.origin.y + label.frame.size.height + kLabelPinVerticalSpacing;
    imageView.frame = rect;
    
    // now create the container view that will embed the 2 elements (label and pin image)
    CGRect frame = CGRectMake(0, 0,
                              label.frame.size.width + 2 * kLabelMarginPadding,
                              imageView.frame.origin.y + imageView.frame.size.height);
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.opaque = NO; // must be set to NO, such that we render the final image with alpha channel
    
    [view addSubview:label];
    [view addSubview:imageView];
    
    return view;
}

@end
