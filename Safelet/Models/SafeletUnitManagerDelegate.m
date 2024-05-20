//
//  SafeletUnitManagerDelegate.m
//  Safelet
//
//  Created by Alexandru Motoc on 18/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "SafeletUnitManagerDelegate.h"

@implementation SafeletUnitManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.disconnectionBlock) {
        self.disconnectionBlock(central, peripheral, error);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    if (self.connectionBlock) {
        self.connectionBlock(central, peripheral);
    }
}

@end
