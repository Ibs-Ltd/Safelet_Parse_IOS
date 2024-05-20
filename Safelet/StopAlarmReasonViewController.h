//
//  StopAlarmReasonViewController.h
//  Safelet
//
//  Created by Alex Motoc on 06/01/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "StopAlarmReason.h"
#import <UIKit/UIKit.h>

@interface StopAlarmReasonViewController : UIViewController

@property (strong, nonatomic) NSArray <NSNumber *> *dataSource;
@property (copy, nonatomic) void(^dismissCompletionBlock)(StopReason reason, NSString *userDetails);

@end
