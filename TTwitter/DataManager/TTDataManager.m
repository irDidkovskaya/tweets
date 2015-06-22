//
//  TTDataManager.m
//  TTwitter
//
//  Created by Iryna Didkovska on 6/18/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import "TTDataManager.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Tweet.h"
#import "TTConstants.h"

@interface TTDataManager()
@property (nonatomic, strong) NSManagedObjectContext *mainManagedObjectContext;
@end


@implementation TTDataManager

+ (instancetype)manager
{
    
    static TTDataManager *dataManager = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{
        
        dataManager = [[self alloc] init];
    });
    
    return dataManager;
}




- (void)saveInfoToCoreData:(NSArray *)data completionHendler:(void(^)(BOOL willLoadNewContent))completionHendler
{
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    self.mainManagedObjectContext = app.managedObjectContext;
    
    NSManagedObjectContext *temporaryContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    temporaryContext.parentContext = self.mainManagedObjectContext;
    
    [temporaryContext performBlock:^{

        __block BOOL willLoadNewContent = NO;
        [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            Tweet *tweet = (Tweet *)[self findInPredicateById:obj[kItemIDParametrKey] inManagedObjectContext:temporaryContext];
            
            if (!tweet)
            {
                tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:temporaryContext];
                
                tweet.itemID = [NSNumber numberWithLong:[obj[kItemIDParametrKey] longValue]];
                tweet.title = obj[kTitleParametrKey];
                tweet.desc = obj[kDescParametrKey];
                
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"ccc MMM dd HH:mm:ss Z yyyy"];
                
                tweet.createdDate = [dateFormatter dateFromString:obj[kCreatedDateParametrKey]];
                
                willLoadNewContent = YES;
                
            }
            
        }];
    
        NSError *error;
        if (![temporaryContext save:&error])
        {
            NSLog(@"temporaryContext error = %@", error.description);
        }
        
        [self.mainManagedObjectContext performBlock:^{
            NSError *error;
            if (![self.mainManagedObjectContext save:&error])
            {
                NSLog(@"mainManagedObjectContext error = %@", error.description);
            }
            
            if (completionHendler) {
                completionHendler(willLoadNewContent);
            }
            
        }];
    }];
    
    
}


- (NSManagedObject *)findInPredicateById:(NSString *)itemId inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ == %@", kItemIDParametrKey, itemId]];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return [fetchedObjects lastObject];
    
}





@end
