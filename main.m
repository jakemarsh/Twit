//
//  main.m
//  Test
//
//  Created by Jake Marsh on 10/2/10.
//  Copyright 2010 Rubber Duck Software. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
    
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, @"AppDelegate");
    [pool release];
    return retVal;
}