//
//  CountryCode.m
//  Safelet
//
//  Created by Mihai Eros on 10/13/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "CountryCode.h"

@implementation CountryCode

+ (instancetype)createWithCountryCode:(NSString *)countryCode
                          countryName:(NSString *)countryName {
    CountryCode *countryCodeModel = [CountryCode new];
    
    countryCodeModel.countryCode = countryCode;
    countryCodeModel.countryName = countryName;
    
    return countryCodeModel;
}

- (NSComparisonResult)localizedCaseInsensitiveCompare:(CountryCode *)other {
    return [self.countryName localizedCaseInsensitiveCompare:other.countryName];
}

+ (NSDictionary *)getMissingCountryCodes {
    NSArray *keys = [NSArray arrayWithObjects:@"AQ", @"BV", @"GS", @"HM", @"PN", @"TF", @"UM", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"672", @"74", @"239", @"334", @"64", @"260", @"1", nil];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects
                                                           forKeys:keys];
    return dictionary;
}

@end
