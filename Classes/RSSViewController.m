//
//  RSSViewController.m
//  Test
//
//  Created by Jake Marsh on 9/25/10.
//  Copyright 2010 Rubber Duck Software. All rights reserved.
//
#import "RSSViewController.h"
#import "AppDelegate.h"
#import "RSSItem.h"
#import "JMBrowserController.h"
#import "MTStatusBarOverlay.h"
#import "NSDateHelper.h"
#import "NSString+HTML.h"
#import "NSStringHelper.h"

#define UPDATE_LIMIT_TIME_IN_SECONDS 60
#define kLastUpdatedTimestampKey @"lastUpdatedRSSTimestamp"

#define kTNTURL @"http://feeds.twit.tv/tnt_video_small"
#define kTWiTURL @"http://feeds.twit.tv/twit_video_small"
#define kiPadTodayURL @"http://feeds.twit.tv/ipad_video_small"
#define kNetAtNiteURL @"http://feeds.twit.tv/natn_video_small"
#define kMBWURL @"http://feeds.twit.tv/mbw_video_small"
#define kTWiGURL @"http://feeds.twit.tv/twig_video_small"
#define kWWURL @"http://feeds.twit.tv/ww_video_small"

@interface RSSViewController ()

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation RSSViewController

@synthesize fetchedResultsController = _fetchedResultsController, managedObjectContext = _managedObjectContext;

#pragma mark Initialization Methods

- (id) initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

    if ((self = [super initWithStyle:style])) {
	    MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
	    overlay.animation = MTStatusBarOverlayAnimationFallDown;  // MTStatusBarOverlayAnimationShrink
	    overlay.historyEnabled = YES;						   // enable automatic history-tracking and show in detail-view	    
    }

    return self;
}

#pragma mark MWFeedParserDelegate

- (void) updateStatus {
	if(_feedsToParse) {
		if(_feedsToParse.count > 0) {
			[[MTStatusBarOverlay sharedInstance] postImmediateMessage:[NSString stringWithFormat:@"Refreshing Feed: %@...", [[_feedsToParse objectAtIndex:0] stringByReplacingOccurrencesOfString:@"http://feeds.twit.tv/" withString:@""]] animated:YES];
		}
	}
}

- (void) refreshFeed {
	if(_feedsToParse == nil) {
		_feedsToParse = [[NSMutableArray arrayWithObjects:kTNTURL, kTWiTURL, kiPadTodayURL, kNetAtNiteURL, kMBWURL, kTWiGURL, kWWURL, nil] retain];
	} else {
		[_feedsToParse release]; _feedsToParse = nil;
		_feedsToParse = [[NSMutableArray arrayWithObjects:kTNTURL, kTWiTURL, kiPadTodayURL, kNetAtNiteURL, kMBWURL, kTWiGURL, kWWURL, nil] retain];			
	}

	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	[activityIndicator release];
	self.navigationItem.rightBarButtonItem = activityItem;
	[activityItem release];

	[self parseNextFeed];
}
- (void) parseNextFeed {
	if(_feedsToParse) {
		if(_feedsToParse.count > 0) {
			MWFeedParser *feedParser = [[[MWFeedParser alloc] initWithFeedURL:[_feedsToParse objectAtIndex:0]] autorelease];
			feedParser.delegate = self;
			feedParser.feedParseType = ParseTypeFull;
			feedParser.connectionType = ConnectionTypeAsynchronously;			

			[self updateStatus];

			[feedParser parse];	
		} else {
			[_feedsToParse release]; _feedsToParse = nil;
		}
	}
}

- (void) feedParserDidStart:(MWFeedParser *)parser {
	if(_parsedItems == nil) _parsedItems = [[NSMutableArray alloc] init];

	[_parsedItems removeAllObjects];
}
- (void) feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
	if (item) {
		[_parsedItems addObject:item];
	}
}
- (void) feedParserDidFinish:(MWFeedParser *)parser {
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(storeItemsInCoreData:) object:_parsedItems];

	[_operationQueue addOperation:operation];

	[operation release];

	dispatch_async(dispatch_get_main_queue(), ^{
		if(_feedsToParse.count > 0) { [_feedsToParse removeObjectAtIndex:0]; }
		[self parseNextFeed];
	});
}

- (RSSItem *) itemForLink:(NSString *)link inManagedObjectContext:(NSManagedObjectContext *)c {
	NSEntityDescription *rssItemEntity = [NSEntityDescription entityForName:@"RSSItem" inManagedObjectContext:c];
	NSFetchRequest *fr = [[NSFetchRequest alloc] init];

	[fr setEntity:rssItemEntity];
	[fr setPredicate:[NSPredicate predicateWithFormat:@"link == %@", link]];
	
	NSError *error = nil;
	NSArray *results = [c executeFetchRequest:fr error:&error];

	[fr release];

	if(!error) {
		if(results.count > 0) {
			return [results objectAtIndex:0];
		} else {
			return nil;
		}
	} else {
		NSLog(@"error = %@", error);
	}
	
	return nil;
	
}
- (void) cacheURL:(NSURL *)url {
	if(!_cachingWebView) _cachingWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1.0, 1.0)];

	[_cachingWebView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void) storeItemsInCoreData:(NSMutableArray *)items_external {
	NSMutableArray *items = [items_external mutableCopy];

    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[(AppDelegate *)[UIApplication sharedApplication].delegate persistentStoreCoordinator]];

    for (MWFeedItem *i in items) {
		//TODO: Don't Re-save items, overwrite them and update.

		RSSItem *item = [self itemForLink:i.link inManagedObjectContext:context];
		if(item == nil) item = [NSEntityDescription insertNewObjectForEntityForName:@"RSSItem" inManagedObjectContext:context];

		[item setValue:i.date forKey:@"createdTimestamp"];
		[item setValue:i.updated forKey:@"updatedTimestamp"];

		item.title = i.title;
		item.createdTimestamp = i.date;
		item.link = i.link;
		item.summary = [i.summary stringByConvertingHTMLToPlainText];
		item.content = i.content;

		if(i.enclosures.count > 0) {		
			NSDictionary *enclosure = [i.enclosures objectAtIndex:0];

			item.enclosureURL = [enclosure objectForKey:@"url"];
			item.enclosureDuration = [NSNumber numberWithInt:[[enclosure objectForKey:@"length"] intValue]];
		}

		[self performSelectorOnMainThread:@selector(cacheURL:) withObject:[NSURL URLWithString:item.link] waitUntilDone:NO];
    }

    NSError *error = nil;
    [context save:&error];

    if (error) NSLog(@"error %@", [error localizedDescription]);

    // free up our context
    [context release];
	[items removeAllObjects];

    // let the app know we're done
    [self performSelectorOnMainThread:@selector(fetch) withObject:nil waitUntilDone:YES];

	if(_feedsToParse.count == 0) {
		[[MTStatusBarOverlay sharedInstance] postFinishMessage:@"Done Refreshing Feeds." duration:2.0];		
		[self performSelectorOnMainThread:@selector(doneRefreshing) withObject:nil waitUntilDone:NO];
	}

	[items release];
}

- (void) doneRefreshing {
	[[NSUserDefaults standardUserDefaults] setFloat:[NSDate timeIntervalSinceReferenceDate] forKey:kLastUpdatedTimestampKey];
	[[NSUserDefaults standardUserDefaults] synchronize];

	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	[refreshItem release];	
}

#pragma mark View Lifecycle Methods

- (void) viewDidLoad {
    [super viewDidLoad];

    if (_operationQueue == nil) _operationQueue = [[NSOperationQueue alloc] init];

	UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed)];
	self.navigationItem.rightBarButtonItem = refreshItem;
	[refreshItem release];
}
- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	BOOL shouldUpdate = NO;
	NSTimeInterval lastUpdateTimestamp = [[NSUserDefaults standardUserDefaults] floatForKey:kLastUpdatedTimestampKey];
	
	if(lastUpdateTimestamp != 0) {
		NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
		CGFloat sinceInSeconds = (now - lastUpdateTimestamp);
		
		if(sinceInSeconds > UPDATE_LIMIT_TIME_IN_SECONDS) {
			shouldUpdate = YES;
		}
	} else {
		shouldUpdate = YES;		
	}

	if(shouldUpdate) [self refreshFeed];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
	return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark UITableViewDataSource Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];

    return [sectionInfo numberOfObjects];
}

- (void) configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	RSSItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];

	if([item.title containsString:@": "]) {
		cell.textLabel.text = [[item.title componentsSeparatedByString:@": "] objectAtIndex:0];
	} else {
		cell.textLabel.text = item.title;
	}
	cell.detailTextLabel.text = [item.createdTimestamp relativeFormattedDateTime];
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"RSSItemCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark UITableViewDelegate Methods

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];

	RSSItem *item = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];

	NSError *setCategoryError = nil;
	[audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
	if (setCategoryError) { /* handle the error condition */ }

	NSError *activationError = nil;
	[audioSession setActive:YES error:&activationError];
	if (activationError) { /* handle the error condition */ }	

	MPMoviePlayerViewController *mpVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:item.enclosureURL]];
	[self presentModalViewController:mpVC animated:YES];
}

#pragma mark FetchedResultsController

- (NSFetchedResultsController *) fetchedResultsController {
    if (_fetchedResultsController != nil) return _fetchedResultsController;

    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"RSSItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];

    // Set the batch size to a suitable number.
	[fetchRequest setFetchBatchSize:20];
	[fetchRequest setFetchLimit:50];

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdTimestamp" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

    [fetchRequest setSortDescriptors:sortDescriptors];

    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																								managedObjectContext:self.managedObjectContext 
																								  sectionNameKeyPath:nil 
																										   cacheName:nil];

    self.fetchedResultsController = aFetchedResultsController;

    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];

    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

    return _fetchedResultsController;
}

#pragma mark FetchedResultsControllerDelegate Methods

- (void) fetch {
    NSError *error = nil;

    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }

	[self.tableView reloadData];
}

#pragma mark Memory Management Methods

- (void) didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}
- (void) viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void) dealloc {
    [_fetchedResultsController release];
    [_managedObjectContext release];

    [super dealloc];
}

@end