//
//  PlayHistoricAlarmRecordingViewController.m
//  Safelet
//
//  Created by Alex Motoc on 17/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "PlayHistoricAlarmRecordingViewController.h"
#import "SLAlarmPlaybackManager.h"

@interface PlayHistoricAlarmRecordingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *replayButton;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) NSTimer *progressUpdateTimer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *bufferingActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSDate *timerStartedDate;
@end

@implementation PlayHistoricAlarmRecordingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setReplayButtonEnabled:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self initializeUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[SLAlarmPlaybackManager sharedManager] startPlayback:self.alarm stateChangedBlock:^(SLAlarmPlaybackState state) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handlePlaybackStateChanged:state];
        });
    }];
}

#pragma mark - Initializations

- (void)initializeUI {
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 15.0f;
    
    self.replayButton.layer.masksToBounds = YES;
    self.replayButton.layer.cornerRadius = self.replayButton.frame.size.height / 2;
}

#pragma mark - User interaction

- (IBAction)didTapClose:(id)sender {
    [self.progressUpdateTimer invalidate];
    
    [[SLAlarmPlaybackManager sharedManager] stopPlayback];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapReplayButton:(id)sender {
    [self setReplayButtonEnabled:NO];
    self.progressUpdateTimer = nil;
    
    [[SLAlarmPlaybackManager sharedManager] startPlayback:self.alarm stateChangedBlock:^(SLAlarmPlaybackState state) {
        [self handlePlaybackStateChanged:state];
    }];
}

#pragma mark - Utils

- (void)updatePlaybackProgress:(NSTimer *)timer {
    NSDate *current = [NSDate date];
    
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSCalendarUnitSecond | NSCalendarUnitMinute
                                                              fromDate:self.timerStartedDate
                                                                toDate:current
                                                               options:0];
    
    self.timeLabel.text = [NSString stringWithFormat:@"%02li:%02li", (long)comps.minute, (long)comps.second];
}

- (void)setReplayButtonEnabled:(BOOL)enabled {
    if (enabled) {
        self.replayButton.backgroundColor = [UIColor darkGrayColor];
    } else {
        self.replayButton.backgroundColor = [UIColor lightGrayColor];
    }
    
    self.replayButton.enabled = enabled;
}

- (void)handlePlaybackStateChanged:(SLAlarmPlaybackState)state {
    if (state == SLAlarmPlaybackStateCompleted) {
        [self.progressUpdateTimer invalidate];
        self.timeLabel.text = @"00:00";
        
        [self setReplayButtonEnabled:YES];
    } else if (state == SLAlarmPlaybackStateBuffering) {
        [self.bufferingActivityIndicator startAnimating];
    } else if (state == SLAlarmPlaybackStatePlaying) {
        if (self.progressUpdateTimer == nil) {
            self.timerStartedDate = [NSDate date];
            self.progressUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                                        target:self
                                                                      selector:@selector(updatePlaybackProgress:)
                                                                      userInfo:nil
                                                                       repeats:YES];
        }
        
        [self.bufferingActivityIndicator stopAnimating];
    }
}

@end
