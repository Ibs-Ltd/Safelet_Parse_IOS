//
//  BaseRequest.m
//  Safelet
//
//  Created by Alex Motoc on 14/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import "BaseRequest.h"
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface BaseRequest()
@property (strong, nonatomic) UIWindow *mainWindow;
@end

@implementation BaseRequest

#pragma mark - Initializations

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showsProgressIndicator = YES;
        self.runsInBackground = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.mainWindow = [UIApplication sharedApplication].keyWindow;
        });
    }
    
    return self;
}

+ (instancetype)request {
    return [self new];
}

#pragma mark - Logic

- (NSString *)requestURL {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass",
                                           NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSDictionary *)params {
    return @{};
}

- (id)handleResponseData:(id)data {
    return data;
}

- (void)runRequest {
    if (self.showsProgressIndicator && [MBProgressHUD HUDForView:self.mainWindow] == nil && self.mainWindow != nil) {
        [MBProgressHUD showHUDAddedTo:self.mainWindow animated:YES];
    }
    
    if (self.runsInBackground) {
        [PFCloud callFunctionInBackground:[self requestURL]
                           withParameters:[self params]
                                    block:^(id  _Nullable response, NSError * _Nullable error) {
                                        if (self.showsProgressIndicator) {
                                            [MBProgressHUD hideHUDForView:self.mainWindow animated:YES];
                                        }
                                        
                                        if (self.requestCompletionBlock) {
                                            self.requestCompletionBlock([self handleResponseData:response], error);
                                        }
                                    }];
    } else {
        NSError *error = nil;
        id response = [PFCloud callFunction:[self requestURL]
                             withParameters:[self params]
                                      error:&error];
        
        if (self.showsProgressIndicator) {
            [MBProgressHUD hideHUDForView:self.mainWindow animated:YES];
        }
        
        if (self.requestCompletionBlock) {
            self.requestCompletionBlock([self handleResponseData:response], error);
        }
    }
}

- (void)setRequestCompletionBlock:(RequestCompletionBlock)requestCompletionBlock {
    _requestCompletionBlock = requestCompletionBlock;
}

@end
