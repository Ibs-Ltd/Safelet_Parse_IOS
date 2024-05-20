//
//  CountryCodeTableViewController.h
//  Safelet
//
//  Created by Mihai Eros on 10/19/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CountryCodeDelegate <NSObject>
@required

- (void)didSelectCountryCode:(NSString *)countryCode;

@end

@interface CountryCodeTableViewController : UITableViewController

@property (weak, nonatomic) id <CountryCodeDelegate> delegate;

@end
