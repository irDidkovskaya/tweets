//
//  TTTableViewController.m
//  TTwitter
//
//  Created by Iryna Didkovska on 6/17/15.
//  Copyright (c) 2015 Iryna Didkovska. All rights reserved.
//

#import "TTTableViewController.h"
#import "TTNetworkManager.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Tweet.h"
#import "TTTweetCell.h"
#import "TTConstants.h"


static NSString *const kTwitterCellIdentifier = @"kTwitterCellIdentifier";


@interface TTTableViewController () <NSFetchedResultsControllerDelegate>
{
    int loadedPages;
    BOOL startReloading;
}
@property (nonatomic, strong) NSMutableArray *tweetsList;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UIView *footerTableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) IBOutlet UILabel *errorLoadingLable;
@end

@implementation TTTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tweetsList = [NSMutableArray array];
    
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appdelegate.managedObjectContext;
    
    [self addedRefreshControl];
    
    self.tableView.estimatedRowHeight = TWEETS_CELL_DEFAULT_HEIGHT;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    
    startReloading = NO;
    loadedPages = 1;
    [self.activityIndicator startAnimating];
    [[TTNetworkManager sharedManager] loadingTweetsPages:1 completionHendler:^(NSString *error) {
        if (error.length)
        {
            self.errorLoadingLable.text = error;
            self.errorLoadingLable.hidden = NO;
        }
        [self.activityIndicator stopAnimating];
    }];

}

- (void)addedRefreshControl
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    self.tableView.alwaysBounceVertical = YES;
    [self.refreshControl addTarget:self
                            action:@selector(refreshTweets)
                  forControlEvents:UIControlEventValueChanged];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResultsController.fetchedObjects.count;
}


- (TTTweetCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTTweetCell *cell = [tableView dequeueReusableCellWithIdentifier:kTwitterCellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(TTTweetCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    Tweet *tweet = self.fetchedResultsController.fetchedObjects[indexPath.row];
    cell.title = tweet.title;
    cell.desc = tweet.desc;
}



#pragma mark getter fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    
    if (_fetchedResultsController) return _fetchedResultsController;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet" inManagedObjectContext:self.managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kCreatedDateParametrKey ascending:NO];
    
    [request setSortDescriptors:@[sortDescriptor]];
    
    
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


#pragma mark FetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(TTTweetCell *)[tableView cellForRowAtIndexPath:indexPath]
                    atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    float offset = (scrollView.contentOffset.y - (scrollView.contentSize.height - scrollView.frame.size.height));
    if (offset >= 0 && offset <= 5) {
        if (!startReloading)
            [self loadMoreData];
    }
}

#pragma mark update contect
- (void)loadMoreData
{
    self.tableView.tableFooterView = self.footerTableView;
    self.footerTableView.hidden = NO;
    self.errorLoadingLable.hidden = YES;
    [self.activityIndicator startAnimating];
    
    startReloading = YES;
    loadedPages = (int)self.fetchedResultsController.fetchedObjects.count/TWEETS_PER_PAGE;
    [[TTNetworkManager sharedManager] getListOfTweetsWithPage:++loadedPages compleationHendler:^(BOOL willLoadNewContent, NSString *error) {
        
        startReloading = NO;
        if (willLoadNewContent)
        {
            self.footerTableView.hidden = YES;
            self.tableView.tableFooterView = nil;
        } else {
            self.errorLoadingLable.text = NSLocalizedString(error, nil);
            self.errorLoadingLable.hidden = NO;
        }
        [self.activityIndicator stopAnimating];
        
    }];
}


- (void)refreshTweets
{
    [[TTNetworkManager sharedManager] loadingTweetsPages:loadedPages completionHendler:^(NSString *error) {
        [self.refreshControl endRefreshing];
        
        if (error.length)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
    }];
     
}

@end
