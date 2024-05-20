//
//  BlockTypes.h
//  Safelet
//
//  Created by Alexandru Motoc on 18/10/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#ifndef BlockTypes_h
#define BlockTypes_h

typedef NS_ENUM(NSInteger, FirmwareUpdateProgressType) {
    FirmwareUpdateProgressTypeDownloading,
    FirmwareUpdateProgressTypeInstalling,
    FirmwareUpdateProgressTypeResetting
};

typedef void(^FirmwareProgress)(float progress, FirmwareUpdateProgressType type);
typedef void(^BluetoothErrorBlock)(NSError *error);

#endif /* BlockTypes_h */
