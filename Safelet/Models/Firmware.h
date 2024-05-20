//
//  Firmware.h
//  Safelet
//
//  Created by Alex Motoc on 30/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Parse/Parse.h>

@interface Firmware : PFObject <PFSubclassing>

@property (strong, nonatomic) NSNumber *versioncode;
@property (strong, nonatomic) NSString *versionname;
@property (strong, nonatomic) NSNumber *firmwareRevision;
@property (strong, nonatomic) NSString *HW_revision_s;
@property (strong, nonatomic) PFFileObject *updatefile;

@end
