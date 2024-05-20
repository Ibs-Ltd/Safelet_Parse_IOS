//
//  AlarmActionsViewController.m
//  Safelet
//
//  Created by Alexandru Motoc on 20/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "AlarmActionsViewController.h"
#import "AlarmChatViewController.h"
#import "SLAlarmManager.h"

static NSString * const kAlarmChatSegueID = @"embedChat";

@interface AlarmActionsViewController ()
@property (weak, nonatomic) IBOutlet UIStackView *buttonContainerStackView;
@property (weak, nonatomic) IBOutlet UIButton *joinAlarmButton;
@property (weak, nonatomic) IBOutlet UIButton *playRecordingButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tapToChatTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatBottomConstraint;
@property (weak, nonatomic) IBOutlet UIView *dragIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *tapToChatContainerView;
@property (strong, nonatomic) UIColor *playRecordingPlayColor;
@property (strong, nonatomic) UIColor *playRecordingStopColor;
@property (strong, nonatomic) Alarm *alarm;
@end

@implementation AlarmActionsViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.joinAlarmButtonEnabled = YES;
        
        if (!self.alarm) {
            self.alarm = [SLAlarmManager sharedManager].alarm;
        }
        
     /*   [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          CGFloat height = [((NSValue *)note.userInfo[UIKeyboardFrameEndUserInfoKey]) CGRectValue].size.height;
                                                          
                                                          self.chatBottomConstraint.constant += height;
                                                          [UIView animateWithDuration:0.3f animations:^{
                                                              [self.view layoutIfNeeded];
                                                              [self.chatViewController scrollToBottomAnimated:YES];
                                                          }];
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                          object:nil
                                                           queue:nil
                                                      usingBlock:^(NSNotification * _Nonnull note) {
                                                          CGFloat height = [((NSValue *)note.userInfo[UIKeyboardFrameEndUserInfoKey]) CGRectValue].size.height;
                                                          
                                                          self.chatBottomConstraint.constant -= height;
                                                          [UIView animateWithDuration:0.3f animations:^{
                                                              [self.view layoutIfNeeded];
                                                          }];
                                                      }]; */
    }
    return self;
}

+ (instancetype)createFromStoryboardWithAlarm:(Alarm *)alarm {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AlarmActionsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"alarmActionsViewController"];
    vc.alarm = alarm;
    return vc;
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.alarm, @"Alarm object must not be nil");
    
    self.playRecordingPlayColor = [UIColor colorWithRed:58.0f/255.0f green:153.0f/255.0f blue:216.0f/255.0f alpha:1];
    self.playRecordingStopColor = [UIColor colorWithRed:53.0f/255.0f green:73.0f/255.0f blue:93.0f/255.0f alpha:1];
    
    if (self.joinAlarmButtonEnabled == NO) {
        [self disableJoinAlarmButton];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.blurViewYPos = self.dragIndicatorView.frame.origin.y - 8; // 8 is padding
    self.collapsedHeight = self.tapToChatContainerView.frame.origin.y + self.tapToChatContainerView.frame.size.height;
}

#pragma mark - Logic

- (void)hideAlarmActionButtons {
    self.buttonContainerStackView.hidden = YES;
    self.tapToChatTopConstraint.constant = 8;
}

- (void)disableJoinAlarmButton {
    self.joinAlarmButton.backgroundColor = [UIColor grayColor];
    self.joinAlarmButton.enabled = NO;
}

- (void)updatePlayAudioButton:(BOOL)isPlaying {
    if (isPlaying) {
        [self.playRecordingButton setTitle:NSLocalizedString(@"Stop recording", nil) forState:UIControlStateNormal];
        self.playRecordingButton.backgroundColor = self.playRecordingStopColor;
    } else {
        [self.playRecordingButton setTitle:NSLocalizedString(@"Play recording", nil) forState:UIControlStateNormal];
        self.playRecordingButton.backgroundColor = self.playRecordingPlayColor;
    }
}

#pragma mark - User interaction

- (IBAction)didTapShowChatButton:(id)sender {
    if ([self.actionsDelegate respondsToSelector:@selector(alarmActionsControllerDidSelectShowChat:)]) {
        [self.actionsDelegate alarmActionsControllerDidSelectShowChat:self];
    }
}

- (IBAction)didTapPlayRecording:(id)sender {
    if ([self.actionsDelegate respondsToSelector:@selector(alarmActionsControllerDidSelectPlayRecording:)]) {
        [self.actionsDelegate alarmActionsControllerDidSelectPlayRecording:self];
    }
}

- (IBAction)didTapJoinAlarm:(id)sender {
    if ([self.actionsDelegate respondsToSelector:@selector(alarmActionsControllerDidSelectJoinAlarm:)]) {
        [self.actionsDelegate alarmActionsControllerDidSelectJoinAlarm:self];
    }
}

- (IBAction)didTapEmergency:(id)sender {
    if ([self.actionsDelegate respondsToSelector:@selector(alarmActionsControllerDidSelectCallEmergency:)]) {
        [self.actionsDelegate alarmActionsControllerDidSelectCallEmergency:self];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kAlarmChatSegueID]) {
        AlarmChatViewController *chatVC = segue.destinationViewController;
        chatVC.alarm = self.alarm;
        chatVC.messageSenderNameColor = self.dragIndicatorView.backgroundColor;
        self.chatViewController = chatVC;
    }
}

@end
