//
//  TTConstants.h
//  TTwitter
//
//  Created by Iryna Didkovska on 6/20/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import <Foundation/Foundation.h>



extern NSString *const kToken;


// static twitter Credantials
extern NSString *const kConsumerKey;
extern NSString *const kConsumerSecret;


// static twitter URLs
extern NSString *const kGetTokenURL;
extern NSString *const kGetTweetsURL;


// static URL json keys
extern NSString *const kCreatedAtURLKey;
extern NSString *const kIdURLKey;
extern NSString *const kTextURLKey;
extern NSString *const kNameURLKey;
extern NSString *const kUserURLKey;
extern NSString *const kStatusesURLKey;
extern NSString *const kAccessTokenURLKey;


// static ParametrsKey
extern NSString *const kTitleParametrKey;
extern NSString *const kDescParametrKey;
extern NSString *const kItemIDParametrKey;
extern NSString *const kCreatedDateParametrKey;



#define TWEETS_PER_PAGE 15
#define TWEETS_CELL_DEFAULT_HEIGHT 44.0



@interface TTConstants : NSObject

@end
