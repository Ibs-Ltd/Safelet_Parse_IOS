//
//  EventsList.m
//  Safelet
//
//  Created by Alex Motoc on 28/10/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "EventsList.h"
#import "Alarm.h"
#import "GuardianInvitation.h"

@implementation EventsList

+ (instancetype)createFromDictionary:(NSDictionary *)dictionary {
    EventsList *eventsList = [self new];
    
    eventsList.alarms = [NSMutableArray arrayWithArray:dictionary[@"alarms"]];
    eventsList.invites = [NSMutableArray arrayWithArray:dictionary[@"invites"]];
    eventsList.checkIns = [NSMutableArray arrayWithArray:dictionary[@"checkIns"]];
    
    return eventsList;
}

- (NSDictionary *)toDictionary {
    NSDictionary *dictionary = @{
                                 @"alarms":self.alarms,
                                 @"invites":self.invites,
                                 @"checkIns":self.checkIns
                                 };
    
    return dictionary;
}

+ (NSArray *)eventsListsArrayFromDictionaryArray:(NSArray *)dictionaryArray {
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaryArray) {
        [array addObject:[EventsList createFromDictionary:dictionary]];
    }
    
    return array;
}

+ (NSArray *)dictionaryArrayFromEventsListsArray:(NSArray *)EventsListsArray {
    NSMutableArray *array = [NSMutableArray array];
    
    for (EventsList *eventsList in EventsListsArray) {
        [array addObject:[eventsList toDictionary]];
    }
    
    return array;
}

- (NSInteger)importantEventsCount {
    NSInteger importantEventsCount = 0;
    
    for (Alarm *object in self.alarms) {
        if ([object isHistoric] == NO) {
            ++importantEventsCount;
        }
    }
    
    for (GuardianInvitation *object in self.invites) {
        if ([object isHistoric] == NO) {
            ++importantEventsCount;
        }
    }
    
    return importantEventsCount;
}

@end
