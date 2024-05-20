//
//  PhoneContactsTableViewController.m
//  Safelet
//
//  Created by Alex Motoc on 07/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "ContactsTableViewController.h"
#import "ContactTableViewCell.h"
#import "User+Requests.h"
#import "Utils.h"
#import "SLContactsUIManager.h"
#import "APContact+FullName.h"
#import "SLErrorHandlingController.h"
#import "SLDataManager.h"
#import "SLNotificationCenterNotifications.h"
#import "GetPhoneContactsManager.h"
#import "PhoneContact.h"
#import <Parse/Parse.h>
#import <APAddressBook/APName.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ContactsTableViewController () <UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, ContactTableViewCellDelegate>

@property (strong, nonatomic) NSArray <NSArray *> *dataSource;
@property (strong, nonatomic) NSMutableArray <PhoneContact *> *filteredCodesResults;
@property (strong, nonatomic) UISearchController *searchController;

@end

@implementation ContactsTableViewController

#pragma mark - ViewController Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Phone contacts", nil);
    
    // get notified when the app wakes from background
    // when that happens, refresh data
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getPhoneContacts:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableData)
                                                 name:SLReloadDataNotification
                                               object:nil];
    
    [self initializePullToRefresh];
    self.tableView.tableFooterView = [UIView new]; // remove extra seprarator lines
    
    [self initializeSearchController];
    if ([SLDataManager sharedManager].phoneContactsMatched == nil) {
        [self getPhoneContacts:YES];
    } else {
        self.dataSource = [GetPhoneContactsManager partitionObjects:[SLDataManager sharedManager].phoneContactsMatched];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.searchController.view removeFromSuperview];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initializations

- (void)initializePullToRefresh {
    
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self
                            action:@selector(getPhoneContactsNoProgress)
                  forControlEvents:UIControlEventValueChanged];
}

- (void)initializeSearchController {
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setFrame:CGRectMake(0, 0, 0, 44)];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}

- (void)filterContentForSearchText:(NSString *)searchText {
    self.filteredCodesResults = [NSMutableArray new];
    
    NSInteger sectionsCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    if (![searchText isEqualToString:@""]) {
        for (NSInteger section = 0; section < sectionsCount; section++) {
            NSMutableArray *sectionArray = [[self.dataSource objectAtIndex:section] mutableCopy];
            
            for (PhoneContact *contact in sectionArray) {
                NSString *name = [contact formattedName];
                
                if (name.length == 0) {
                    continue;
                }
                
                if ([[[name substringToIndex:1] lowercaseString] isEqualToString:[[searchText substringToIndex:1] lowercaseString]]) {
                    if ([name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [self.filteredCodesResults addObject:contact];
                    } else {
                        section++;
                    }
                }
            }
        }
    }
}

#pragma mark - UISearchResultsUpdating Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    
    [self filterContentForSearchText:searchString];
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchController.isActive) {
        return 1;
    }
    
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return  self.filteredCodesResults.count;
    }
    
    return [[self.dataSource objectAtIndex:section] count];
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.searchController.isActive) {
        return nil;
    }
    
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (self.searchController.isActive) {
        return nil;
    }
    
    BOOL showSection = [[self.dataSource objectAtIndex:section] count] != 0;
    
    return showSection ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (self.searchController.active) {
        return 0;
    }
    
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactTableViewCellReuseIdentifier
                                                                 forIndexPath:indexPath];
    PhoneContact *contact = nil;
    if (self.searchController.isActive) {
        contact = [self.filteredCodesResults objectAtIndex:indexPath.row];
    } else {
        contact = [[self.dataSource objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row];
    }
    
    [cell populateWithPhoneContact:contact delegate:self];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PhoneContact *contact = nil;
    if (self.searchController.isActive) {
        contact = [self.filteredCodesResults objectAtIndex:indexPath.row];
    } else {
        contact = [[self.dataSource objectAtIndex:indexPath.section ] objectAtIndex:indexPath.row];
    }
    return [ContactTableViewCell heightForContact:contact];
}

#pragma mark - ContactTableViewCellDelegate

- (void)updateContact:(PhoneContact *)contact status:(PhoneContactStatus)status {
    [contact updateStatus:status];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:SLReloadDataNotification object:nil];
}

- (void)contactsCellDidSelectRequestGuardian:(PhoneContact *)contact {
    if (contact.status == PhoneContactStatusNotMember) {
        [[SLContactsUIManager sharedManager] showSMSInvitationScreenForPhoneNumbers:@[contact.phoneNumber]
                                                                        contactName:[NSString stringWithFormat:@"%@ %@",contact.firstName,contact.lastName]
                                                           presentingViewController:self
                                                                         completion:^(BOOL success) {
                                                                             if (success == NO) {
                                                                                 return;
                                                                             }
                                                                             [self updateContact:contact status:PhoneContactStatusSMSInvited];
                                                                         }];
        return;
    }
    
    [[User currentUser] inviteUserAsGuardian:contact.userObjectId completion:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            [SLErrorHandlingController handleError:error];
            return;
        }
        [self updateContact:contact status:PhoneContactStatusInvited];
    }];
}

- (void)contactsCellDidSelectCancelGuardianRequest:(PhoneContact *)contact {
    if (contact.status == PhoneContactStatusSMSInvited) {
        [[User currentUser] cancelSMSInvitation:contact.phoneNumber completion:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                [SLErrorHandlingController handleError:error];
                return;
            }
            [self updateContact:contact status:PhoneContactStatusNotMember];
        }];
        return;
    }
    
    [[User currentUser] cancelGuardianInvitationSentToUser:contact.userObjectId
                                                completion:^(BOOL success, NSError * _Nullable error) {
                                                    if (error) {
                                                        [SLErrorHandlingController handleError:error];
                                                        return;
                                                    }
                                                    [self updateContact:contact status:PhoneContactStatusUninvited];
                                                }];
}

#pragma mark - Data retrieval

// used for pull-to-refresh functionality
- (void)getPhoneContactsNoProgress {
    [self getPhoneContacts:NO];
}

/**
 *  Retrieves phone contacts and maps them to existing Parse users, after which reloads the tableView data.
 */
- (void)getPhoneContacts:(BOOL)showProgressIndicator {
    MBProgressHUD *hud = nil;
    
    if (showProgressIndicator) {
        // adds a progress HUD animated
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    
    [[SLDataManager sharedManager] fetchPhoneContactsWithCompletion:^(NSArray<PhoneContact *> * _Nonnull phoneContacts, NSError * _Nonnull error) {
        [hud hideAnimated:YES];
        [self hideRefreshControl];
        
        if (error) {
            [SLErrorHandlingController handleError:error];
            return;
        }
        
        self.dataSource = [GetPhoneContactsManager partitionObjects:phoneContacts];
        [self.tableView reloadData];
    }];
}

#pragma mark - Utils

- (void)reloadTableData {
    [self.tableView reloadData];
}

- (void)hideRefreshControl {
    if (self.refreshControl.isRefreshing) {
        [self.refreshControl performSelector:@selector(endRefreshing)
                                  withObject:nil
                                  afterDelay:0.1f];
    }
}

@end
