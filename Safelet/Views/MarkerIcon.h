//
//  MarkerIcon.h
//  Safelet
//
//  Created by Alex Motoc on 13/04/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkerIcon : NSObject

+ (UIImage *)markerIconWithLabelText:(NSString *)text labelMaxWidth:(CGFloat)maxWidth pinIcon:(UIImage *)pinIcon;
+ (UIView *)markerViewWithLabelText:(NSString *)text labelMaxWidth:(CGFloat)maxWidth pinIcon:(UIImage *)pinIcon;

@end
