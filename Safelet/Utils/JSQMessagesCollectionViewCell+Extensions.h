//
//  JSQMessagesCollectionViewCell+Extensions.h
//  Safelet
//
//  Created by Alexandru Motoc on 03/08/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessagesViewController.h>
@class FirebaseMessage;
@interface JSQMessagesCollectionViewCell (Extensions)
- (void)populateWithFirebaseMessage:(FirebaseMessage *)message currentUserIsSender:(BOOL)currentUserIsSender;
@end
