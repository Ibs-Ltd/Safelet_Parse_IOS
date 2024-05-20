//
//  GetConnectionsManager.m
//  Safelet
//
//  Created by Alex Motoc on 01/11/2016.
//  Copyright © 2016 X2 Mobile. All rights reserved.
//

#import "User+Requests.h"
#import "GetConnectionsManager.h"

static NSString * const kGetConnectionsRequestCountKey = @"operationCount";

@interface GetConnectionsManager ()
@property (strong, nonatomic) NSOperationQueue *getConnectionsOperationQueue;
@property (strong, nonatomic) NSError *getConenctionsError;
@property (strong, nonatomic) NSArray *guardians;
@property (strong, nonatomic) NSArray *guarded;
@property (nonatomic, copy) void (^getConnectionsCompletionBlock)(NSArray *, NSArray *, NSError *);
@end

@implementation GetConnectionsManager

+ (instancetype)sharedManager {
    static GetConnectionsManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self new];
        
        manager.getConnectionsOperationQueue = [NSOperationQueue new];
        [manager.getConnectionsOperationQueue addObserver:manager
                                               forKeyPath:kGetConnectionsRequestCountKey
                                                  options:NSKeyValueObservingOptionNew
                                                  context:NULL];
    });
    
    return manager;
}

- (void)dealloc {
    [self.getConnectionsOperationQueue removeObserver:self forKeyPath:kGetConnectionsRequestCountKey];
}

#pragma mark - logic

- (void)fetchConnectionsWithCompletion:(void (^)(NSArray *guardians, NSArray *guarded, NSError *error))completion {
    self.getConnectionsCompletionBlock = completion;
    
    [self.getConnectionsOperationQueue addOperationWithBlock:^{
        [[User currentUser] fetchListOfGuardiansWithCompletion:^(NSArray<User *> * _Nullable response,
                                                                 NSError * _Nullable error) {
            self.guardians = response;
            self.getConenctionsError = error;
        }];
    }];
    
    [self.getConnectionsOperationQueue addOperationWithBlock:^{
        [[User currentUser] fetchListOfGuardedWithCompletion:^(NSArray<User *> * _Nullable response,
                                                               NSError * _Nullable error) {
            self.guarded = response;
            self.getConenctionsError = error;
        }];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:kGetConnectionsRequestCountKey] && [object isEqual:self.getConnectionsOperationQueue]) {
        NSUInteger opCount = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        
        if (opCount == 0) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if (self.getConnectionsCompletionBlock) {
                    self.getConnectionsCompletionBlock(self.guardians, self.guarded, self.getConenctionsError);
                }
            }];
        }
    }
}

@end
