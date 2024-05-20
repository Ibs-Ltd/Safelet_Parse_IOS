//
//  JSQMessage+FirebaseMessage.m
//  Safelet
//
//  Created by Alexandru Motoc on 27/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "FirebaseMessage.h"
#import "JSQMessage+FirebaseMessage.h"

@implementation JSQMessage (FirebaseMessage)

+ (instancetype)messageWithFirebaseMessage:(FirebaseMessage *)message {
    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:message.sender.objectId
                                                 displayName:[message.sender originalName]
                                                        text:message.text];
    
    return jsqMessage;
}

@end
