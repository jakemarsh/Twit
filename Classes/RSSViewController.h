//
//  RSSViewController.h
//  Test
//
//  Created by Jake Marsh on 9/25/10.
//  Copyright 2010 Rubber Duck Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MWFeedParser.h"

@class RSSItem;

@interface RSSViewController : UITableViewController <MWFeedParserDelegate> {	
	NSOperationQueue *_operationQueue;
	MWFeedParser *_feedParser;
	NSMutableArray *_feedsToParse;
	NSMutableArray *_parsedItems;
	
	UIActivityIndicatorView *_barButtonItemActivityView;
	UIBarButtonItem	*_loadingIndicatorBarButtonItem;
	UIBarButtonItem *_refreshBarButtonItem;
	
	NSTimeInterval _lastUpdateTimestamp;
	
	UIWebView *_cachingWebView;

@private
    NSFetchedResultsController *_fetchedResultsController;
    NSManagedObjectContext *_managedObjectContext;	
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void) refreshFeed;
- (void) fetch;
- (void) doneRefreshing;

- (RSSItem *) itemForLink:(NSString *)link inManagedObjectContext:(NSManagedObjectContext *)c;
- (void) cacheURL:(NSURL *)url;

- (void) parseNextFeed;


@end