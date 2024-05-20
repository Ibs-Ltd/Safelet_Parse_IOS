//
//  ContactTableViewCell.h
//  Safelet
//
//  Created by Alex Motoc on 08/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhoneContact;

@protocol ContactTableViewCellDelegate <NSObject>
- (void)contactsCellDidSelectRequestGuardian:(PhoneContact *)contact;
- (void)contactsCellDidSelectCancelGuardianRequest:(PhoneContact *)contact;
@end

static NSString * const kContactTableViewCellReuseIdentifier = @"contactTableViewCell";

@interface ContactTableViewCell : UITableViewCell
@property (weak, nonatomic) id <ContactTableViewCellDelegate> delegate;
- (void)populateWithPhoneContact:(PhoneContact *)contact delegate:(id<ContactTableViewCellDelegate>)delegate;
+ (CGFloat)heightForContact:(PhoneContact *)contact;

@end
