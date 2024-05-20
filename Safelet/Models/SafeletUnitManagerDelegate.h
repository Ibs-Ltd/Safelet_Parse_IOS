//
//  SafeletUnitManagerDelegate.h
//  Safelet
//
//  Created by Alexandru Motoc on 18/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

typedef void(^DisconnectionBlock)(CBCentralManager *central, CBPeripheral *peripheral, NSError *error);
typedef void(^ConnectionBlock)(CBCentralManager *central, CBPeripheral *peripheral);

@interface SafeletUnitManagerDelegate : NSObject <CBCentralManagerDelegate>
@property (copy, nonatomic) DisconnectionBlock disconnectionBlock;
@property (copy, nonatomic) ConnectionBlock connectionBlock;
@end
