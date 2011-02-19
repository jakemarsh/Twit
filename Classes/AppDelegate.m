//
//  TestAppDelegate.m
//  Test
//
//  Created by Jake Marsh on 10/2/10.
//  Copyright 2010 Rubber Duck Software. All rights reserved.
//

#import "AppDelegate.h"
#import "RSSViewController.h"

@implementation AppDelegate

@synthesize window = _window, rssViewController = _rssViewController;

#pragma mark Application Lifecycle Methods

- (BOOL) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

	_rssViewController = [[RSSViewController alloc] initWithStyle:UITableViewStylePlain];
	_rssViewController.title = @"Episodes";
	_rssViewController.managedObjectContext = self.managedObjectContext;

	UINavigationController *rssNC = [[UINavigationController alloc] initWithRootViewController:_rssViewController];
	[_rssViewController release];

    // Add the view controller's view to the window and display.
    [_window addSubview:rssNC.view];
    [_window makeKeyAndVisible];

    return YES;
}
- (void) applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}
- (void) applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}
- (void) applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}
- (void) applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}
- (void) applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark Core Data Methods

- (void) saveContext {
    NSError *error = nil;

    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            NSLog(@"Unresolved Error %@, %@", error, [error userInfo]);
        } 
    }
}

- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) return _managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];

    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }

    return _managedObjectContext;
}
- (NSManagedObjectModel *) managedObjectModel {
    if (_managedObjectModel != nil) return _managedObjectModel;

    NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"CoreData" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];

    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *) persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) return _persistentStoreCoordinator;

    NSURL *storeURL = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"CoreData.sqlite"]];

    NSError *error = nil;

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
		
        NSLog(@"Unresolved Error %@, %@", error, [error userInfo]);
    }

    return _persistentStoreCoordinator;
}

- (NSString *) applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark Memory Management Methods

- (void) applicationDidReceiveMemoryWarning:(UIApplication *)application {
	
}
- (void) dealloc {
    [_rssViewController release];
    [_window release];

    [super dealloc];
}

@end