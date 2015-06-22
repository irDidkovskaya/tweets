//
//  TTNetworkManager.m
//  TTwitter
//
//  Created by Iryna Didkovska on 6/17/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import "TTNetworkManager.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "TTDataManager.h"
#import "TTConstants.h"
#import "TTNetworkManager+Foundation.h"



@implementation TTNetworkManager
+ (instancetype)sharedManager
{
    static TTNetworkManager *sharedObject = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}



- (void)getTempTokenWithCompletionHandler:(void(^)(NSString *token, NSString *error))completionHandler
{
    
    [self executeRequestWithType:TTNetworkRequestTypePOST URLString:kGetTokenURL params:@{@"grant_type":@"client_credentials"} completionHandler:^(id object, NSError *error) {
        
        NSString *token = nil;
        NSString *errorString = nil;
        
        if (!error && object)
        {
            [self setToken:object[kAccessTokenURLKey]];
            token = object[kAccessTokenURLKey];
        } else {
            errorString = NSLocalizedString(@"Error verify your token", nil);
        }
        
        completionHandler(token, errorString);
        
        
    } completionHandlerQueue:dispatch_get_main_queue()];
    
    
}


- (void)getTweetsPages:(int)pages withCompletionHandler:(void(^)(NSArray *tweetsDict, NSString *error))completionHandler
{
    
    NSString *urlString = [NSString stringWithFormat:@"%@%d", kGetTweetsURL, pages*TWEETS_PER_PAGE];
    [self executeRequestWithType:TTNetworkRequestTypeGET URLString:urlString params:nil completionHandler:^(id object, NSError *error) {
        
        NSArray *parcedData = nil;
        NSString *errorString = nil;
        
        if (!error)
        {
            parcedData = [self parceTweets:object];
        } else {
            errorString = error.localizedDescription;
        }
        
        completionHandler(parcedData, errorString);
        
    } completionHandlerQueue:dispatch_get_main_queue()];
}




- (NSArray *)parceTweets:(NSDictionary *)dict
{
    NSArray *array = dict[kStatusesURLKey];
    NSMutableArray *tweets = [NSMutableArray array];
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        [tweets addObject:@{ kTitleParametrKey: obj[kUserURLKey][kNameURLKey], kDescParametrKey:obj[kTextURLKey], kItemIDParametrKey: obj[kIdURLKey], kCreatedAtURLKey : obj[kCreatedAtURLKey]}];
    }];
    
    return tweets;
}


- (void)loadingTweetsPages:(int)page completionHendler:(void(^)(NSString *error))completionHendler
{
    if (![self getToken])
    {
        [self getTempTokenWithCompletionHandler:^(NSString *token, NSString *error) {
            if (!error.length)
            {
            [self getTweetsPages:page withCompletionHandler:^(NSArray *tweetsDict, NSString *error) {
                
                if (tweetsDict)
                {
                    [[TTDataManager manager] saveInfoToCoreData:tweetsDict completionHendler:nil];
                    completionHendler(nil);
                }
                else
                {
                    completionHendler(error);
                    NSLog(@"getTweetsPages errorDescription = %@", error);
                }
                
            }];
            } else {
                completionHendler(error);
                
            }
        }];
    } else {
        
        [self getTweetsPages:page withCompletionHandler:^(NSArray *tweetsDict, NSString *error) {
            
            if (tweetsDict)
            {
                [[TTDataManager manager] saveInfoToCoreData:tweetsDict completionHendler:nil];
                completionHendler(nil);
            }
            else
            {
                completionHendler(error);
                NSLog(@"getTweetsPages errorDescription = %@", error);
            }
            
        }];
    }
}


- (void)getListOfTweetsWithPage:(int)page compleationHendler:(void(^)(BOOL willLoadNewContent, NSString *error))completionHendler
{
    [self getTweetsPages:page withCompletionHandler:^(NSArray *tweetsDict, NSString *error) {
        
        if (tweetsDict)
        {
            [[TTDataManager manager] saveInfoToCoreData:tweetsDict completionHendler:^(BOOL willLoadNewContent) {
                completionHendler(willLoadNewContent, NSLocalizedString(@"No more contact avalible", nil));
            }];
        }
        else
        {
            NSLog(@"getTweetsPages errorDescription = %@", error);
            completionHendler(NO, error);
            
        }
        
    }];
}


@end
