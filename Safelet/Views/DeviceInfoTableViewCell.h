//
//  DeviceInfoTableViewCell.h
//  Safelet
//
//  Created by Alex Motoc on 06/05/16.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceInfoTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

+ (NSString *)reuseIdentifier;

@end
