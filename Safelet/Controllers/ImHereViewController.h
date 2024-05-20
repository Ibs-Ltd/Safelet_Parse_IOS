//
//  ImHereViewController.h
//  Safelet
//
//  Created by Ram on 24/01/19.
//  Copyright © 2019 X2 Mobile. All rights reserved.
//
#import "BannerEnabledViewController.h"
#import <UIKit/UIKit.h>
#import "SLLocationManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImHereViewController : BannerEnabledViewController<UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *checkInLocationName;
@property (nonatomic) CLLocation *checkInLocation;


@end

NS_ASSUME_NONNULL_END
