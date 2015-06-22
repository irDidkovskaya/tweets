//
//  Tweet.h
//  TTwitter
//
//  Created by Iryna Didkovska on 6/20/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * itemID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * createdDate;

@end
