//
//  GetConnectionsManager.h
//  Safelet
//
//  Created by Alex Motoc on 01/11/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetConnectionsManager : NSObject

+ (instancetype)sharedManager;

- (void)fetchConnectionsWithCompletion:(void(^)(NSArray *guardians, NSArray *guarded, NSError *error))completion;

@end
