//
//  EventTypeSegmentedControl.m
//  Safelet
//
//  Created by Alex Motoc on 28/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "EventTypeSelectorView.h"

static CGFloat const kViewHeight = 50;

@interface EventTypeSelectorView ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) id <EventTypeSegmentedControlDelegate> delegate;
@end

@implementation EventTypeSelectorView

#pragma mark - Initializations

- (instancetype)init {
    self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                         owner:self
                                       options:nil][0];
    return self;
}

+ (instancetype)createWithDelegate:(id<EventTypeSegmentedControlDelegate>)delegate
                defaultContentType:(EventContentType)defaultType {
    EventTypeSelectorView *view = [self new];
    
    view.delegate = delegate;
    
    [view.segmentedControl addTarget:view
                              action:@selector(controlValueChanged:)
                    forControlEvents:UIControlEventValueChanged];
    [view setEventContentType:defaultType];
    
    return view;
}

#pragma mark - Logic

- (void)controlValueChanged:(UISegmentedControl *)control {
    EventContentType type;
    
    switch (control.selectedSegmentIndex) {
        case 0:
            type = EventContentTypeAlarms;
            break;
        case 1:
            type = EventContentTypeInvitations;
            break;
        case 2:
            type = EventContentTypeCheckIns;
            break;
        default:
            type = EventContentTypeAlarms;
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(eventTypeSegmentedControl:didSelectContentType:)]) {
        [self.delegate eventTypeSegmentedControl:self didSelectContentType:type];
    }
}

+ (CGFloat)viewHeight {
    return kViewHeight;
}

- (void)setEventContentType:(EventContentType)type {
    switch (type) {
        case EventContentTypeAlarms:
            self.segmentedControl.selectedSegmentIndex = 0;
            break;
        case EventContentTypeInvitations:
            self.segmentedControl.selectedSegmentIndex = 1;
            break;
        case EventContentTypeCheckIns:
            self.segmentedControl.selectedSegmentIndex = 2;
            break;
        default:
            self.segmentedControl.selectedSegmentIndex = 0;
            break;
    }
}

@end
