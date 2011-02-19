//
//  RSSItem.h
//  CodePlex
//
//  Created by Jake Marsh on 9/25/10.
//  Copyright 2010 Rubber Duck Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RSSItem : NSManagedObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *link;
@property (nonatomic, retain) NSDate *createdTimestamp;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSNumber *enclosureDuration;
@property (nonatomic, retain) NSString *enclosureURL;

@end