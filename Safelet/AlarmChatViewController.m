//
//  AlarmChatViewController.m
//  Safelet
//
//  Created by Alexandru Motoc on 24/07/2017.
//  Copyright © 2017 X2 Mobile. All rights reserved.
//

#import "AlarmChatViewController.h"
#import "User.h"
#import "Alarm.h"
#import "FirebaseMessage.h"
#import "JSQMessage+FirebaseMessage.h"
#import "JSQMessagesCollectionViewCell+Extensions.h"
#import "SLNotificationCenterNotifications.h"
@import FirebaseDatabase;

@interface AlarmChatViewController ()
@property (strong, nonatomic) NSMutableArray <FirebaseMessage *> *messages;
@property (strong, nonatomic) FIRDatabaseReference *channelRef;
@property (nonatomic) FIRDatabaseHandle channelRefHandle;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingMessageImage;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingMessageImage;
@end

@implementation AlarmChatViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.messages = [NSMutableArray array];
        self.senderId = [User currentUser].objectId;
        self.senderDisplayName = [User currentUser].name;
        self.messageSenderNameColor = [UIColor darkGrayColor];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.alarm, @"the Alarm object must not be nil");
    
    [self setupMessagesController];
    [self setupFirebaseMessages];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:true];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:true];
}


- (void)dealloc {
    if (self.channelRefHandle) {
        [self.channelRef removeObserverWithHandle:self.channelRefHandle];
    }
}

#pragma mark - setup

- (void)setupFirebaseMessages {
    self.channelRef = [[[[FIRDatabase database] reference] child:@"messages"] child:self.alarm.objectId];
    
    __block BOOL onceFlag = NO;
    
    FIRDatabaseQuery *query = [self.channelRef queryLimitedToLast:25];
    self.channelRefHandle = [query observeEventType:FIRDataEventTypeChildAdded
                                          withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
                                              if (onceFlag == NO) {
                                                  onceFlag = YES;
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:SLAlarmChatHasContentNotification
                                                                                                      object:nil];
                                              }
                                              
                                              FirebaseMessage *firebaseMessage = [FirebaseMessage createFromDictionary:snapshot.value];
                                              [self.messages addObject:firebaseMessage];
                                              
                                              [self finishReceivingMessage];
                                          }];
}

- (void)setupMessagesController {
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    //self.keyboardController = nil; // no auto handling of keyboard dismiss
    UIColor *gray = [[UIColor jsq_messageBubbleLightGrayColor] jsq_colorByDarkeningColorWithValue:0.1f];
    
    self.incomingMessageImage = [[JSQMessagesBubbleImageFactory new] incomingMessagesBubbleImageWithColor:gray];
    self.outgoingMessageImage = [[JSQMessagesBubbleImageFactory new] outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    
    CGSize avatarSize = CGSizeMake(kJSQMessagesCollectionViewAvatarSizeDefault, kJSQMessagesCollectionViewAvatarSizeDefault);
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = avatarSize;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = avatarSize;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
}

#pragma mark - JSQMessages

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    cell.textView.userInteractionEnabled = NO;
    FirebaseMessage *message = self.messages[indexPath.item];
    [cell populateWithFirebaseMessage:message currentUserIsSender:[self currentUserIsSender:message.sender.objectId]];
    
    return cell;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    FirebaseMessage *message = self.messages[indexPath.item];
    return [JSQMessage messageWithFirebaseMessage:message];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    FirebaseMessage *message = self.messages[indexPath.item];
    if ([self currentUserIsSender:message.sender.objectId]) {
        return self.outgoingMessageImage;
    }
    return self.incomingMessageImage;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    FirebaseMessage *message = self.messages[indexPath.item];
    
    NSString *name = [message.sender originalName] ?: @"No name";
    if ([message.sender.objectId isEqualToString:self.senderId]) {
        name = NSLocalizedString(@"You", nil);
    }
    
    return [[NSAttributedString alloc] initWithString:name attributes:@{
                                                                        NSFontAttributeName:[UIFont systemFontOfSize:12],
                                                                        NSForegroundColorAttributeName:self.messageSenderNameColor
                                                                        }];
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 20;
}

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    [self.inputToolbar.contentView.textView resignFirstResponder];
    FIRDatabaseReference *messageRef = [self.channelRef childByAutoId];
    FirebaseMessage *message = [FirebaseMessage messageFromUser:[User currentUser] withText:text];
    [messageRef setValue:[message toDictionary]];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    [self finishSendingMessage];
}

- (void) didPressAccessoryButton:(UIButton *)sender {
    
}
#pragma mark - Utils

- (BOOL)currentUserIsSender:(NSString *)senderId {
    return [[User currentUser].objectId isEqualToString:senderId];
}

- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //[self.view endEditing:true];
}

@end
