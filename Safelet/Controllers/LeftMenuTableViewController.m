//
//  LefMenuViewController.m
//  Safelet
//
//  Created by Mihai Eros on 9/28/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "LeftMenuTableViewController.h"
#import "User+Requests.h"
#import "SLDataManager.h"
#import "SLErrorHandlingController.h"
#import "SLNotificationCenterNotifications.h"
#import "SafeletUnitManager.h"
#import "Utils.h"
#import "SlideMenuMainViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "User.h"
#import <SDWebImage/UIImageView+WebCache.h>

static NSInteger const kConnectSafeletIndexPathRow = 8;

@interface LeftMenuTableViewController () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *communityCheckMarkImageView;
@property (weak, nonatomic) IBOutlet UILabel *eventsCountLabel;
@property (nonatomic) BOOL internetConnectionAvailable;
@property (nonatomic) BluetoothConnectionStatus bluetoothStatus;
@end

@implementation LeftMenuTableViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentContentType = SLContentTypeHome;
    
    // add this view controller as observer for important events count change
    [[SLDataManager sharedManager] addObserver:self
                                    forKeyPath:kImportantEventsCountKeyPath
                                       options:NSKeyValueObservingOptionNew
                                       context:NULL];
    
    // needed to avoid the menu table view overlap with the status bar
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.delegate = self;
    
    [self initializeReachability];
    [self initializeBluetoothInteraction];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SLBraceletBatteryChangedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self handleBatteryChangedNotification:note];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SLBluetoothStateChangedNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self handleBluetoothStatusChangedNotification:note];
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SLUserProfileNotification
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      [self handleUserProfileChangedNotification:note];
                                                  }];
    
    // this ensures the event count is updated
    [[SLDataManager sharedManager] fetchEventsWithProgressIndicator:NO completion:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [self updateUserUI];
}

- (void)updateUserUI {
    User *currentUser = [User currentUser];
    self.lblName.text = [currentUser originalName];
    self.imgUser.layer.cornerRadius = self.imgUser.frame.size.width/2;
    if (currentUser.userImage) {
        [self.imgUser sd_setImageWithURL:[NSURL URLWithString:currentUser.userImage.url]
                        placeholderImage:[UIImage imageNamed:@"generic_icon"]];
    }
}

- (void)dealloc {
    [[SLDataManager sharedManager] removeObserver:self forKeyPath:kImportantEventsCountKeyPath];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - initializations

- (void)initializeReachability {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable) {
            self.internetConnectionAvailable = NO;
        } else {
            self.internetConnectionAvailable = YES;
        }
        
        [self.tableView reloadData];
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)initializeBluetoothInteraction {
    self.bluetoothStatus = [SafeletUnitManager shared].currentBluetoothStatus;
    [self.tableView reloadData];
}

- (void)handleBatteryChangedNotification:(NSNotification *)notification {
    NSNumber *batteryLevel = notification.userInfo[SLBraceletBatteryChangedNotification];
    [Utils dispatchLocalNotificationForLowBatteryLevel:batteryLevel.integerValue];
    [self.tableView reloadData];
}

- (void)handleBluetoothStatusChangedNotification:(NSNotification *)notification {
    NSNumber *state = notification.userInfo[SLBluetoothStateChangedNotification];
    self.bluetoothStatus = state.integerValue;
    [self.tableView reloadData];
}

- (void)handleUserProfileChangedNotification:(NSNotification *)notification {
    [self updateUserUI];
}

/**
 *  Method used in order to place the green check mark image if user is a community member
 *  and remove it if it's not a community member.
 */
- (void)placeCheckMarkForCommunityMember {
    if ([User currentUser].isCommunityMember) {
        self.communityCheckMarkImageView.hidden = NO;
    } else {
        self.communityCheckMarkImageView.hidden = YES;
    }
    
    self.eventsCountLabel.layer.masksToBounds = YES;
    self.eventsCountLabel.layer.cornerRadius = self.eventsCountLabel.frame.size.width / 2;
}

#pragma mark - TableViewDataSource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"";
    }
    
    NSString *title = @"";
    
    if (self.internetConnectionAvailable == NO && section == 0) {
        title = NSLocalizedString(@"No internet connection", nil);
    } else if (self.internetConnectionAvailable == YES && section == 0) {
        return @"";
    } else {
        switch (self.bluetoothStatus) {
            case BluetoothConnectionStatusPoweredOff:
                title = NSLocalizedString(@"Bluetooth powered off", nil);
                break;
            case BluetoothConnectionStatusUnauthorized:
                title = NSLocalizedString(@"Bluetooth authorization denied", nil);
                break;
            case BluetoothConnectionStatusUnsupported:
                title = NSLocalizedString(@"Bluetooth not supported", nil);
                break;
            case BluetoothConnectionStatusConnected: {
                NSInteger batteryLevel = [SafeletUnitManager shared].safeletPeripheral.batteryLevel;
                if (batteryLevel == -1) {
                    title = NSLocalizedString(@"Fetching battery level", nil);
                    break;
                }
                
                [Utils dispatchLocalNotificationForLowBatteryLevel:batteryLevel];
                
                title = NSLocalizedString(@"Safelet connected.\nBattery level", nil);
                title = [title stringByAppendingString:[NSString stringWithFormat:@" %ld%%", (long)batteryLevel]];
                break;
            }
            case BluetoothConnectionStatusDisconnected:
                title = NSLocalizedString(@"Lost connection with Safelet", nil);
                break;
            case BluetoothConnectionStatusNoSafeletRelation:
                title = NSLocalizedString(@"No relation with Safelet", nil);
                break;
            default:
                break;
        }
    }
    
    return title;
}

#warning too much code that creates UI => separate in a custom view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, self.tableView.bounds.size.width - 15, 30)];
    label.text = [self tableView:tableView titleForHeaderInSection:section];
    label.numberOfLines = 0;
    label.font = [UIFont boldSystemFontOfSize:17];
    label.textColor = tableView.tableHeaderView.backgroundColor;
    [label sizeToFit];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, label.frame.size.height + 4)];
    header.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.599];
    
    [header addSubview:label];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    UIView *header = [self tableView:tableView viewForHeaderInSection:section];
    return header.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section == 1) {//indexPath.row != kConnectSafeletIndexPathRow &&
        return  cell;
    }
    
    if ([SafeletUnitManager shared].safeletPeripheral) {
        cell.textLabel.text = NSLocalizedString(@"Disconnect Safelet", nil);
    } else {
        cell.textLabel.text = NSLocalizedString(@"Connect Safelet", nil);
    }
    
    if (self.bluetoothStatus == BluetoothConnectionStatusPoweredOff ||
        self.bluetoothStatus == BluetoothConnectionStatusUnauthorized ||
        self.bluetoothStatus == BluetoothConnectionStatusUnsupported) {
        
        cell.contentView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.100];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.145 green:0.404 blue:0.604 alpha:1.000];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    return cell;
}

#pragma mark - TableView delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView didSelectRowAtIndexPath:indexPath]; // need this so automatic segues trigger
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - KVO (important events count change)

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:kImportantEventsCountKeyPath]) {
        NSNumber *eventsCount = change[NSKeyValueChangeNewKey];
        if ([eventsCount intValue] > 0) {
            self.eventsCountLabel.hidden = NO;
        } else {
            self.eventsCountLabel.hidden = YES;
        }
        self.eventsCountLabel.text = eventsCount.stringValue;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    SlideMenuMainViewController *main = (SlideMenuMainViewController *)self.mainVC;
    
    if ([segue.identifier isEqualToString:main.gettingStartedSegueIdentifier]) {
        self.currentContentType = SLContentTypeGettingStarted;
    }
    if ([segue.identifier isEqualToString:main.homeSegueIdentifier]) {
        self.currentContentType = SLContentTypeHome;
    }
    if ([segue.identifier isEqualToString:main.myConnectionsSegueIdentifier]) {
        self.currentContentType = SLContentTypeMyConnections;
    }
    
    if ([segue.identifier isEqualToString:main.eventsSegueIdentifier]) {
        self.currentContentType = SLContentTypeEvents;
    }
    
    if ([segue.identifier isEqualToString:main.myProfileSegueIdentifier]) {
        self.currentContentType = SLContentTypeMyProfile;
    }
    
    if ([segue.identifier isEqualToString:main.guardianNetworkSegueIdentifier]) {
        self.currentContentType = SLContentTypeGuardianNetwork;
    }
    
    if ([segue.identifier isEqualToString:main.alarmSegueIdentifier]) {
        self.currentContentType = SLContentTypeAlarm;
    }
    
    if ([segue.identifier isEqualToString:main.checkInSegueIdentifier]) {
        self.currentContentType = SLContentTypeCheckIn;
    }
    
    if ([segue.identifier isEqualToString:main.optionsSegueIdentifier]) {
        self.currentContentType = SLContentTypeOptions;
    }
}

@end
