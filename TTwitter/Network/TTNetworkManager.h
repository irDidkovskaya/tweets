//
//  TTNetworkManager.h
//  TTwitter
//
//  Created by Iryna Didkovska on 6/17/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTNetworkManager : NSObject
+ (instancetype)sharedManager;

- (void)loadingTweetsPages:(int)page completionHendler:(void(^)(NSString *error))completionHendler;
- (void)getListOfTweetsWithPage:(int)page compleationHendler:(void(^)(BOOL willLoadNewContent, NSString *error))completionHendler;


// for test
- (void)getTempTokenWithCompletionHandler:(void(^)(NSString *token, NSString *error))completionHandler;
@end
