//
//  TestAppDelegate.h
//  Test
//
//  Created by Jake Marsh on 10/2/10.
//  Copyright 2010 Rubber Duck Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class RSSViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;

    RSSViewController *_rssViewController;
	
@private
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) RSSViewController *rssViewController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *) applicationDocumentsDirectory;
- (void) saveContext;

@end