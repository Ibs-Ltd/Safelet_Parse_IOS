//
//  EventTypeSegmentedControl.h
//  Safelet
//
//  Created by Alex Motoc on 28/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "GenericConstants.h"
#import <UIKit/UIKit.h>

@class EventTypeSelectorView;
@protocol EventTypeSegmentedControlDelegate <NSObject>
- (void)eventTypeSegmentedControl:(EventTypeSelectorView *)control didSelectContentType:(EventContentType)contentType;
@end

@interface EventTypeSelectorView : UIView

+ (instancetype)createWithDelegate:(id<EventTypeSegmentedControlDelegate>)delegate
                defaultContentType:(EventContentType)defaultType;
+ (CGFloat)viewHeight;

- (void)setEventContentType:(EventContentType)type;
//Main message, notificatoin and product menu option changes
@end
