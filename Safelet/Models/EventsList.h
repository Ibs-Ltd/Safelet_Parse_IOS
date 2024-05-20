//
//  EventsList.h
//  Safelet
//
//  Created by Alex Motoc on 28/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventsList : NSObject

@property (strong, nonatomic) NSArray *alarms;
@property (strong, nonatomic) NSArray *invites;
@property (strong, nonatomic) NSArray *checkIns;
@property (nonatomic, readonly) NSInteger importantEventsCount;

+ (instancetype)createFromDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;
+ (NSArray *)eventsListsArrayFromDictionaryArray:(NSArray *)dictionaryArray;
+ (NSArray *)dictionaryArrayFromEventsListsArray:(NSArray *)EventsListsArray;

@end
