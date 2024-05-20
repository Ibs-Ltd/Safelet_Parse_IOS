//
//  SyncContactsRequest.h
//  Safelet
//
//  Created by Alex Motoc on 25/05/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@class User, PhoneContact;
@interface SyncContactsRequest : BaseRequest

+ (instancetype)requestWithUser:(User *)user contactsList:(NSArray <PhoneContact *> *)contactsList;

@end
