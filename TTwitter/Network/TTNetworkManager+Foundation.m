//
//  TTNetworkManager+Foundation.m
//  TTwitter
//
//  Created by Iryna Didkovska on 6/21/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import "TTNetworkManager+Foundation.h"
#import "TTConstants.h"


static const NSTimeInterval kTimeoutInterval = 30.0;
static dispatch_queue_t _network_queue;

@interface TTNetworkManager ()
@property dispatch_queue_t network_queue;
@end

@implementation TTNetworkManager (Foundation)


- (NSURLSessionTask *)executeRequestWithType:(TTNetworkRequestType)type
                                   URLString:(NSString *)urlString
                                      params:(NSDictionary *)params
                           completionHandler:(TTNetworkManagerResponseHandler)handler
                      completionHandlerQueue:(dispatch_queue_t)queue
{
    __block NSURLSessionTask *task;
    
    dispatch_async(self.network_queue, ^{
        
        void (^responseHandler)(NSData *, NSHTTPURLResponse *, NSError *) = ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
            id responseObject = nil;
            if (data.length) {
                
                NSString *myString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                
                NSLog(@"URL = %@", response.URL);
                NSLog(@"myString = %@", myString);
                NSError *errorParce;
                responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&errorParce];
                dispatch_async(queue, ^{
                    handler(responseObject, errorParce);
                });
            } else {
                dispatch_async(queue, ^{
                    handler(nil, error);
                });
            }
            
        };
        
        if (type == TTNetworkRequestTypeGET) {
            task = [self createAndProccessGETRequestWithURLString:urlString
                                                           params:params
                                                completionHandler:responseHandler];
        } else if (type == TTNetworkRequestTypePOST) {
            task = [self createAndProccessPOSTRequestWithURLString:urlString
                                                            params:params
                                                 completionHandler:responseHandler];
        }
    });
    
    return task;
}


- (NSURLSessionTask *)createAndProccessPOSTRequestWithURLString:(NSString *)url
                                                         params:(NSDictionary *)params
                                              completionHandler:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))handler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    
    if (params) {

        NSData *data = [[self urlEncodedString:params] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        [request setHTTPBody:data];
    }
    
    
    [request setValue:[self getBase64EncodeString] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    
    //
    request.timeoutInterval = kTimeoutInterval;
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                 handler(data, (NSHTTPURLResponse *)response, error);
                                                             }];
    [task resume];
    
    return task;
}

#pragma mark - GET

- (NSURLSessionTask *)createAndProccessGETRequestWithURLString:(NSString *)url
                                                        params:(NSDictionary *)params
                                             completionHandler:(void (^)(NSData *data, NSHTTPURLResponse *response, NSError *error))handler
{
    NSString *urlString = [url copy];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    
    request.timeoutInterval = kTimeoutInterval;
    
    NSString *token = [NSString stringWithFormat:@"Bearer %@", [self getToken]];
    
    [request addValue:token forHTTPHeaderField:@"Authorization"];
    
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                 handler(data, (NSHTTPURLResponse *)response, error);
                                                             }];
    [task resume];
    
    return task;
}


- (NSString *)urlEncodedString:(NSDictionary *)dict
{
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in dict) {
        id value = [dict objectForKey:key];
        NSString *part = [NSString stringWithFormat:@"%@=%@", key, value];
        [parts addObject:part];
    }
    return [parts componentsJoinedByString:@"&"];
}



- (dispatch_queue_t)network_queue
{
    if (!_network_queue) {
        _network_queue = dispatch_queue_create("com.tweet.network.queue", DISPATCH_QUEUE_CONCURRENT);
    }
    return _network_queue;
}


- (NSString *)getBase64EncodeString {
    
    NSString *consumerKey = [kConsumerKey stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSString *consumerSecret = [kConsumerSecret stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    
    NSString *concatenateKeyAndSecret = [NSString stringWithFormat:@"%@:%@", consumerKey, consumerSecret];
    
    NSData *secretAndKeyData = [concatenateKeyAndSecret dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion: YES];
    
    NSString *base64EncodeKeyAndSecret = [secretAndKeyData base64EncodedStringWithOptions:0];
    
    return [NSString stringWithFormat:@"Basic %@", base64EncodeKeyAndSecret];
}


- (NSString *)getToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kToken];
}


- (void)setToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kToken];
}


@end
