//
//  AlarmChatViewController.h
//  Safelet
//
//  Created by Alexandru Motoc on 24/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//


@import JSQMessagesViewController;
@import Foundation;

@class Alarm;
@interface AlarmChatViewController : JSQMessagesViewController
@property (strong, nonatomic) Alarm *alarm;
@property (strong, nonatomic) UIColor *messageSenderNameColor;
@end
