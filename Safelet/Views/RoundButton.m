//
//  RoundButton.m
//  Safelet
//
//  Created by Alex Motoc on 28/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "RoundButton.h"

@implementation RoundButton

- (void)drawRect:(CGRect)rect {
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = (self.frame.size.width + self.frame.size.height) / 4;
}

@end
