//
//  MyConnectionsViewController.m
//  Safelet
//
//  Created by Mihai Eros on 9/30/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "MyConnectionsViewController.h"
#import "Utils.h"
#import "User+Requests.h"
#import "ConnectionCell.h"
#import "SLContactsUIManager.h"
#import "SLErrorHandlingController.h"
#import "SlideMenuMainViewController.h"
#import "LeftMenuTableViewController.h"
#import "SLDataManager.h"
#import "SLNotificationCenterNotifications.h"
#import "SLMenuSelectionController.h"
#import <MBProgressHUD/MBProgressHUD.h>

static NSString * const kContactsSegueIdentifier = @"contactsSegue";

@interface MyConnectionsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIView *noGuardiansView;
@property (weak, nonatomic) IBOutlet UIView *noGuardedView;

@property (nonatomic, assign) SLGuardianStatus state;
@end

@implementation MyConnectionsViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fetchConnections:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCollectionData)
                                                 name:SLReloadDataNotification
                                               object:nil];

    
    [self.segmentedControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateSelected];
    [self didTapSegmentedControl:self.segmentedControl]; // for initialization purposes
    
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
   // if ([SLDataManager sharedManager].didLoadMyConnections == NO) {
        [self fetchConnections:nil];
   // }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UICollectionView datasource

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    if (self.state == SLGuardianStatusMyGuardian) {
        return [SLDataManager sharedManager].guardianUsers.count + 1; // + 1 marks the first cell that represents the 'add new guardian' button
    } else {
        return [SLDataManager sharedManager].guardedUsers.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ConnectionCell *cell = (ConnectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kcellConnectionIdentifier
                                                                                       forIndexPath:indexPath];
    
    NSInteger index = indexPath.row;
    
    if (index == 0 && self.state == SLGuardianStatusMyGuardian) {
        [cell populateWithUser:nil];
    } else if (self.state == SLGuardianStatusMyGuardian) {
        // subtract 1 in order to ignore the first cell which is the 'add new guardian' button
        [cell populateWithUser:[[SLDataManager sharedManager].guardianUsers objectAtIndex:index - 1]];
    } else {
        [cell populateWithUser:[[SLDataManager sharedManager].guardedUsers objectAtIndex:index]];
    }
    
    return cell;
}

#pragma mark - UICollectionView delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && self.state == SLGuardianStatusMyGuardian) {
        [self performSegueWithIdentifier:kContactsSegueIdentifier sender:nil];
    } else {
        BOOL isGuardian = NO;
        NSArray *dataSource = [SLDataManager sharedManager].guardedUsers;
        NSInteger index = indexPath.row;
        
        if (self.state == SLGuardianStatusMyGuardian) {
            isGuardian = YES;
            dataSource = [SLDataManager sharedManager].guardianUsers;
            --index; // subtract 1 because of default "ADD" cell
        }
        
        NSArray <UIAlertAction *> *actions = nil;
        NSString *actionSheetMessage = nil;
        NSString *actionSheetMessageFormat = NSLocalizedString(@"Actions for %@", @"The actions that are available when selecting a contact");
        
        User *aUser = dataSource[index];
        
        actionSheetMessage = [NSString stringWithFormat:actionSheetMessageFormat, aUser.name];
        actions = [SLContactsUIManager getActionSheetActionsForOtherUser:aUser
                                                        guardianStatus:self.state
                                              presentingViewController:self
                                            removeConnectionCompletion:^(BOOL success, NSError * _Nullable error) {
                                                if (!success) {
                                                    if (error) {
                                                        [SLErrorHandlingController handleError:error];
                                                    } else {
                                                        NSString *errMsg = NSLocalizedString(@"Remove failed", nil);
                                                        [UIAlertController showErrorAlertWithMessage:errMsg];
                                                    }
                                                } else {
                                                    [[SLDataManager sharedManager] removeConnection:aUser isGuardian:isGuardian];
                                                    [self didTapSegmentedControl:self.segmentedControl];
                                                }
                                            }];
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                                 message:actionSheetMessage
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        for (UIAlertAction *action in actions) {
            [alertController addAction:action];
        }
        
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }
}

#pragma mark - IBActions

/**
 *  If segmented control is tapped the state is modified in SLGuardianStatusMyGuardian or
 *  SLGuardianStatusGuarding, this way we know which array must be used as dataSource
 *  Also, it hides or not the noGuardiansView and reloads data from collectionView
 *
 *  @param sender IBAction action
 */
- (IBAction)didTapSegmentedControl:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        self.state = SLGuardianStatusMyGuardian;
        self.noGuardedView.hidden = YES;
        
        if ([SLDataManager sharedManager].guardianUsers.count > 0) {
            self.noGuardiansView.hidden = YES;
            
            [self.collectionView reloadData];
            self.collectionView.hidden = NO;
        } else {
            self.noGuardiansView.hidden = NO;
            self.collectionView.hidden = YES;
        }
    } else if (self.segmentedControl.selectedSegmentIndex == 1) {
        self.state = SLGuardianStatusGuarding;
        self.noGuardiansView.hidden = YES;
        
        if ([SLDataManager sharedManager].guardedUsers.count > 0) {
            self.noGuardedView.hidden = YES;
            
            [self.collectionView reloadData];
            self.collectionView.hidden = NO;
        } else {
            self.noGuardedView.hidden = NO;
            self.collectionView.hidden = YES;
        }
    }
}

- (IBAction)didTapCheckInButton:(id)sender {
    SlideMenuMainViewController *menu = [SlideMenuMainViewController currentMenu];
    [menu.leftMenu performSegueWithIdentifier:menu.checkInSegueIdentifier sender:self];
}

#pragma mark - Utils

- (void)reloadCollectionData {
    [self didTapSegmentedControl:self.segmentedControl];
}

- (void)fetchConnections:(id)object {
    MBProgressHUD *hud = nil;
    if (object == nil) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [[SLDataManager sharedManager] fetchConnectionsWithCompletion:^(NSArray *guardians, NSArray *guarded, NSError *error) {
        [hud hideAnimated:YES];
        
        if (error) {
            [SLErrorHandlingController handleError:error];
            return;
        }
        
        [self didTapSegmentedControl:self.segmentedControl];
    }];
}

@end
