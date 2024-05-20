//
//  DeviceInfoTableViewController.m
//  Safelet
//
//  Created by Alex Motoc on 06/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "DeviceInfoTableViewController.h"
#import "SafeletUnitManager.h"
#import "DeviceInfoTableViewCell.h"

static NSString *const kDataSourceTitleKey = @"title";
static NSString *const kDataSourceValueKey = @"value";

@interface DeviceInfoTableViewController ()
@property (strong, nonatomic) NSArray <NSDictionary *> *dataSource;
@end

@implementation DeviceInfoTableViewController

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self populateDataSource];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DeviceInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[DeviceInfoTableViewCell reuseIdentifier]
                                                                    forIndexPath:indexPath];
    
    cell.titleLabel.text = self.dataSource[indexPath.row][kDataSourceTitleKey];
    cell.infoLabel.text = self.dataSource[indexPath.row][kDataSourceValueKey];
    
    return cell;
}

#pragma mark - Utils

- (void)populateDataSource {
    SafeletDeviceInfoService *service = [SafeletUnitManager shared].safeletPeripheral.deviceInfo;
    
    NSMutableArray *array = [NSMutableArray array];
    NSString *title, *value;
    NSMutableDictionary *dict;
    
    title = NSLocalizedString(@"Manufacturer name", nil);
    value = service.manufacturerName;
    dict = [NSMutableDictionary dictionary];
    dict[kDataSourceTitleKey] = title;
    dict[kDataSourceValueKey] = value;
    [array addObject:dict];
    
    title = NSLocalizedString(@"Model number", nil);
    value = service.modelNumber;
    dict = [NSMutableDictionary dictionary];
    dict[kDataSourceTitleKey] = title;
    dict[kDataSourceValueKey] = value;
    [array addObject:dict];
    
    title = NSLocalizedString(@"Hardware revision", nil);
    value = service.hardwareRev;
    dict = [NSMutableDictionary dictionary];
    dict[kDataSourceTitleKey] = title;
    dict[kDataSourceValueKey] = value;
    [array addObject:dict];
    
    
    title = NSLocalizedString(@"Firmware revision", nil);
    value = service.firmwareRev;
    dict = [NSMutableDictionary dictionary];
    dict[kDataSourceTitleKey] = title;
    dict[kDataSourceValueKey] = value;
    [array addObject:dict];
    
    self.dataSource = [NSArray arrayWithArray:array];
}

@end
