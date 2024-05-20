//
//  FetchEventsRequest.h
//  Safelet
//
//  Created by Alex Motoc on 29/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "EventsList.h"
#import "BaseRequest.h"

@interface FetchEventsRequest : BaseRequest

/**
 *	Constructor to get the list of events for a user. Events can be alarms dispatched by users guarded
 *  by the provided user, pending guardian invitations sent to the provided user, check-ins created by 
 *  users guarded by the provided user
 *
 *  If the provided user is also a community guardian, retrieves also the alerts dispatched in a 1 kilometer radius,
 *  no matter if the users that dispatched those alarms are guarded by the provided user or not
 *
 *	@param objectId	the objectId of the user we want to find events for
 *
 *	@return - upon success return an array of events (alerts, pending invitations, check-ins)
 *          - upon error return the encountered error
 */

+ (instancetype _Nonnull)requestWithUserObjectId:(NSString * _Nonnull)objectId
                           includeHistoricEvents:(BOOL)includeHistoric;

@end
