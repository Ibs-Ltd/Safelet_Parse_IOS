//
//  JSQMessagesCollectionViewCell+Extensions.m
//  Safelet
//
//  Created by Alexandru Motoc on 03/08/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "JSQMessagesCollectionViewCell+Extensions.h"
#import "FirebaseMessage.h"
@import SDWebImage;

@implementation JSQMessagesCollectionViewCell (Extensions)
- (void)populateWithFirebaseMessage:(FirebaseMessage *)message currentUserIsSender:(BOOL)currentUserIsSender {
    if (currentUserIsSender) {
        self.textView.textColor = [UIColor whiteColor];
    } else {
        self.textView.textColor = [UIColor blackColor];
    }
    
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.cornerRadius = kJSQMessagesCollectionViewAvatarSizeDefault / 2.0f;
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:message.imageURL] placeholderImage:[UIImage imageNamed:@"generic_icon"]];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp];
    NSString *formattedDate = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterLongStyle];
    
    self.cellBottomLabel.attributedText = [[NSAttributedString alloc] initWithString:formattedDate attributes:@{
                                                                                                                NSFontAttributeName:[UIFont systemFontOfSize:10],
                                                                                                                NSForegroundColorAttributeName:[UIColor grayColor]
                                                                                                                }];
    
}
@end
