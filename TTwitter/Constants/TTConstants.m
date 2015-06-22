//
//  TTConstants.m
//  TTwitter
//
//  Created by Iryna Didkovska on 6/20/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import "TTConstants.h"



NSString *const kToken = @"kToken";



// static twitter Credantials
NSString *const kConsumerKey = @"gy5WyspTvDeukLQpyEauIxXhF";
NSString *const kConsumerSecret = @"qfywSzSeUGh4qPh7TbIEI4miTU7FERuPjaI4QBfYhLg7khkEDs";


// static twitter URLs
NSString *const kGetTokenURL = @"https://api.twitter.com/oauth2/token";
NSString *const kGetTweetsURL = @"https://api.twitter.com/1.1/search/tweets.json?q=%40apple&count=";


// static URL json keys
NSString *const kCreatedAtURLKey = @"created_at";
NSString *const kIdURLKey = @"id";
NSString *const kTextURLKey = @"text";
NSString *const kNameURLKey = @"name";
NSString *const kUserURLKey = @"user";
NSString *const kStatusesURLKey = @"statuses";
NSString *const kAccessTokenURLKey = @"access_token";



// static ParametrsKey
NSString *const kTitleParametrKey = @"title";
NSString *const kDescParametrKey = @"desc";
NSString *const kItemIDParametrKey = @"itemID";
NSString *const kCreatedDateParametrKey = @"createdDate";







@implementation TTConstants

@end
