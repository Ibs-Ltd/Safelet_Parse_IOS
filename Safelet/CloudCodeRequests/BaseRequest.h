//
//  BaseRequest.h
//  Safelet
//
//  Created by Alex Motoc on 14/10/15.
//  Copyright © 2015 X2 Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestCompletionBlock)(id _Nullable response, NSError * _Nullable error);

/**
 *	Base class to be used for requests. All future requests should inherit from this class
 *  Right now, it is a wraper around the PFCloud backend mechanism
 *  When a request is run, this class automatically displays a progress indicatior on the app's window
 *  You can provide a completion block to be executed, using: `setRequestCompletionBlock:`
 */
@interface BaseRequest : NSObject

@property (copy, nonatomic) RequestCompletionBlock _Nullable requestCompletionBlock; // block called upon success
@property (nonatomic) BOOL showsProgressIndicator; // defaults to YES
@property (nonatomic) BOOL runsInBackground; // defaults to YES

+ (instancetype _Nonnull)request; // default constructor
- (nonnull NSString *)requestURL; // must be overridden in a subclass; return the name of the Cloud Code method to be called
// if not overridden, returns an empty dictionary; can be overridden to return a dictionary of parameters
- (NSDictionary * _Nonnull)params;
//if not overridden, returns the request response data as it arrives; can be overridden to return custom objects based on the received data
- (id _Nullable)handleResponseData:(id _Nullable)data;
- (void)runRequest; // must be called in order to start the request

// required setter such that autocomplete detects the block's parameters
- (void)setRequestCompletionBlock:(RequestCompletionBlock _Nullable)requestCompletionBlock;

@end
