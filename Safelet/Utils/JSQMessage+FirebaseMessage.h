//
//  JSQMessage+FirebaseMessage.h
//  Safelet
//
//  Created by Alexandru Motoc on 27/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

@import JSQMessagesViewController;

@class FirebaseMessage;
@interface JSQMessage (FirebaseMessage)

+ (instancetype)messageWithFirebaseMessage:(FirebaseMessage *)message;

@end
