//
//  TTNetworkManager+Foundation.h
//  TTwitter
//
//  Created by Iryna Didkovska on 6/21/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import "TTNetworkManager.h"


typedef enum {
    TTNetworkRequestTypeGET = 0,
    TTNetworkRequestTypePOST = 1
} TTNetworkRequestType;

typedef void(^TTNetworkManagerResponseHandler)(id object, NSError *error);


@interface TTNetworkManager (Foundation)
- (NSURLSessionTask *)executeRequestWithType:(TTNetworkRequestType)type
                                   URLString:(NSString *)urlString
                                      params:(NSDictionary *)params
                           completionHandler:(TTNetworkManagerResponseHandler)handler
                      completionHandlerQueue:(dispatch_queue_t)queue;

- (NSString *)getToken;
- (void)setToken:(NSString *)token;
@end
