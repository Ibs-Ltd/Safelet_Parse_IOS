//
//  SafeletBatteryService.h
//  Safelet
//
//  Created by Alex Motoc on 10/06/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseService.h"

/**
 *  Provides information about the bracelet's battery level. Also keeps track of the local notifications
 *  dispatched when the battery is low. There must be only 2 local notifications to let the user know the
 *  bracelet's battery level is low. One will be shown when the battery reaches 20% and the other when 
 *  it reaches 10%.
 */

@interface SafeletBatteryService : BaseService

+ (int)serviceUUID;
@property (strong, nonatomic) BaseCharacteristic *battery;

@end
