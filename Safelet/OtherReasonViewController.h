//
//  OtherReasonViewController.h
//  Safelet
//
//  Created by Alex Motoc on 09/01/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherReasonViewController : UIViewController

@property (copy, nonatomic) void(^dismissCompletionBlock)(NSString *userDescription);

@end
