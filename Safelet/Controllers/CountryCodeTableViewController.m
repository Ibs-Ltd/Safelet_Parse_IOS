//
//  CountryCodeTableViewController.m
//  Safelet
//
//  Created by Mihai Eros on 10/19/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CountryCodeTableViewController.h"
#import "CountryCode.h"

@import libPhoneNumber_iOS;

@interface CountryCodeTableViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) NSArray *countryCodesArray;
@property (strong, nonatomic) NSMutableArray *filteredCodesResults;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSString *selectedCountryName;

@end

static NSString *kCellIdentifier = @"countryCodeCellIdentifier";

@implementation CountryCodeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initializeSearchController];
    [self getCountryCodes];
    
    // countryCodesArray gets populated with sorted objects (Users or APContacts) alphabetically by name
    self.countryCodesArray = [self partitionObjects:self.countryCodesArray collationStringSelector:@selector(countryName)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.searchController.view removeFromSuperview];
}

#pragma mark - Initializations

- (void)initializeSearchController {
    // settings needed for a proper searchBar animation when it gets active
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES; // allows the searchBar to overlap on the navigationBar
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.delegate = self;
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar setFrame:CGRectMake(0, 0, 0, 44)];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
}
/**
 *  This method takes the first letter entered in the searchTextField
 *  and after that it's looking at every CountryCode.countryName to be
 *  in rangeOfString of the text entered in the searchTextField.
 *
 *  @param searchText filters the countryCodes array by section
 */
- (void)filterContentForSearchText:(NSString *)searchText {
    self.filteredCodesResults = [NSMutableArray new];
    
    NSInteger sectionsCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
    if (![searchText isEqualToString:@""]) {
        for (NSInteger section = 0; section < sectionsCount; section++) {
            NSMutableArray *sectionArray = [self.countryCodesArray objectAtIndex:section];
            
            for (CountryCode *item in sectionArray) {
                if ([[[item.countryName substringToIndex:1] lowercaseString] isEqualToString:[[searchText substringToIndex:1] lowercaseString]]) {
                    if ([item.countryName rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [self.filteredCodesResults addObject:item];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // if searchController is active 1 section must be returned
    if (self.searchController.isActive) {
        return 1;
    }
    // otherwise the number of sectionTitles from currentCollation is used
    return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // if searchController is active it returns the number of filteredResults
    if (self.searchController.isActive) {
        return  self.filteredCodesResults.count;
    }
    // otherwise the number of rows it's exactly the number of countryCodes existing in countryCodesArray
    return [[self.countryCodesArray objectAtIndex:section] count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    // if searchController is active we return nil, as we don't need index titles for sections
    if (self.searchController.isActive) {
        return nil;
    }
    // otherwise we display index titles for every section using sectionIndexTitles on currentCollation
    return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    // if searchController is active
    if (self.searchController.isActive) {
        return nil;
    }
    
    BOOL showSection = [[self.countryCodesArray objectAtIndex:section] count] != 0;
    //only show the section title if there are rows in the section
    
    // if showSection is true it returns sectionTitles, otherwise nil
    return showSection ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    // if searchController is active it returns 0, as it does not need any titles because there is only one section available
    if (self.searchController.active) {
        return 0;
    }
    
    //sectionForSectionIndexTitleAtIndex: is a bit buggy, but is still useable
    return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    
    CountryCode *element = nil;
    
    if (self.searchController.isActive) {
        element = [self.filteredCodesResults objectAtIndex:indexPath.row];
    } else {
        element = [[self.countryCodesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = element.countryName;
    cell.detailTextLabel.text = element.countryCode;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CountryCode *countryCodeModel = nil;
    
    if (self.searchController.isActive) {
        countryCodeModel = [self.filteredCodesResults objectAtIndex:indexPath.row];
    } else {
        countryCodeModel = [[self.countryCodesArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    [self.delegate didSelectCountryCode:countryCodeModel.countryCode];
    self.selectedCountryName = countryCodeModel.countryName;
    
    // after populating with the right object from the selected indexPath, if searchController is active
    // it has to set it as inactive in order to dismiss the searchBar from the navigationBar
    if (self.searchController.isActive) {
        [self.searchController setActive:NO];
    }
    
    // it also dismisses the currentVC after the user selected a cell
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utils

/**
 *  Method used to partition objects using sections using a collation string selector.
 *  It's using an array with country codes and returns an array with sections, each section
 *  being sorted alphabetically using the country name.
 *
 *  @param array    countryCodesArray
 *  @param selector implies that we transmit as a param a getter method name
 *
 *  @return sections
 */

- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; //section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    //put each object into a section
    for (id object in array) {
        
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //sort each section
    for (NSMutableArray *section in unsortedSections) {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}

/**
 *  Retrieves and sets the property named countryCodesArray with objects 
 */

- (void)getCountryCodes {
    NSDictionary *dict = [CountryCode getMissingCountryCodes];
    
    NSMutableArray *countryCodesArray = [NSMutableArray new];
    NSArray *metaDataArray = [[NBMetadataHelper new] getAllMetadata];
    
    [metaDataArray enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *letterCountryCode = [obj objectForKey:@"code"]; // example RO for Romania
        
        NSString *countryCodeNumber = [NBMetadataHelper countryCodeFromRegionCode:[obj objectForKey:@"code"]]; // example + 40 for Romania
        if (!countryCodeNumber) {
            countryCodeNumber = [dict objectForKey:letterCountryCode]; // code if number unavailable for country
        }
        
        if (!countryCodeNumber) {
            return;
        }
        
        // add a '+' to the country code
        countryCodeNumber = [@"+" stringByAppendingString:countryCodeNumber];
        CountryCode *countryCode = [CountryCode createWithCountryCode:countryCodeNumber
                                                          countryName:[obj objectForKey:@"name"]];
        [countryCodesArray addObject:countryCode];
    }];
    
    self.countryCodesArray = [NSMutableArray arrayWithArray:countryCodesArray];
}

#pragma mark - IBActions

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
