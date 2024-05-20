//
//  CountryCode.h
//  Safelet
//
//  Created by Mihai Eros on 10/13/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CountryCode : NSObject

@property (strong, nonatomic) NSString *countryCode;
@property (strong, nonatomic) NSString *countryName;

+ (instancetype)createWithCountryCode:(NSString *)countryCode
                          countryName:(NSString *)countryName;

- (NSComparisonResult)localizedCaseInsensitiveCompare:(CountryCode *)other;

/**
 *  Returns an NSDictionary containing the missing
 *  country codes from libPhoneNumber
 *
 *  @return NSDictionary with missing countryCodes
 */

+ (NSDictionary *)getMissingCountryCodes;

@end
