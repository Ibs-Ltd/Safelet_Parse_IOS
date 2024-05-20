//
//  NotifyParticipantsWhenCalledEmergency.h
//  Safelet
//
//  Created by Alex Motoc on 31/03/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"

@interface NotifyParticipantsWhenCalledEmergency : BaseRequest

+ (instancetype _Nonnull)requestWithAlarmObjectId:(NSString * _Nonnull)alarmObjId;

@end
