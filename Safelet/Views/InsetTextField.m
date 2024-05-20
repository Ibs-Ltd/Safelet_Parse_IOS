//
//  InputTextField.m
//  Safelet
//
//  Created by Mihai Eros on 9/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "InsetTextField.h"

@implementation InsetTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:CGRectMake(bounds.origin.x + 10,
                                               bounds.origin.y,
                                               bounds.size.width - 20,
                                               bounds.size.height)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [self textRectForBounds:bounds];
}

@end
