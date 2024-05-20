//
//  Firmware.m
//  Safelet
//
//  Created by Alex Motoc on 30/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "Firmware.h"

@implementation Firmware

@dynamic versioncode;
@dynamic versionname;
@dynamic updatefile;
@dynamic firmwareRevision;
@dynamic HW_revision_s;

+ (NSString *)parseClassName {
    return @"Firmware";
}

+ (void)load {
    [self registerSubclass];
}

- (NSString *)description {
    NSString *content = @"";
    
    if (self.HW_revision_s.length > 0) {
        content = [content stringByAppendingFormat:@"Hardware revision: %@\n", self.HW_revision_s];
    }
    if (self.firmwareRevision != nil) {
        content = [content stringByAppendingFormat:@"Firmware revision: %ld\n", (long)self.firmwareRevision.integerValue];
    }
    if (self.versionname.length > 0) {
        content = [content stringByAppendingFormat:@"Version name: %@\n", self.versionname];
    }
    if (self.versioncode != nil) {
        content = [content stringByAppendingFormat:@"Version code: %ld\n ", (long)self.versioncode.integerValue];
    }
    
    return content;
}

@end
