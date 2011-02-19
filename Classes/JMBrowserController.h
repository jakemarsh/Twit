//
//  JMBrowserController.h
//  CodePlex
//
//  Created by Jake Marsh on 9/26/10.
//  Copyright 2010 Rubber Duck Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@protocol JMBrowserControllerDelegate;

@interface JMBrowserController : UIViewController <UIWebViewDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate> {
	id<JMBrowserControllerDelegate> _delegate;
	UIWebView* _webView;
	UIToolbar* _toolbar;
	UIView* _headerView;

	UIBarButtonItem* _backButton;
	UIBarButtonItem* _forwardButton;
	UIBarButtonItem* _refreshButton;
	UIBarButtonItem* _stopButton;
	UIBarButtonItem* _activityItem;
}

@property (nonatomic,assign) id<JMBrowserControllerDelegate> delegate;
@property (nonatomic,readonly) NSURL* url;
@property (nonatomic,retain) UIView* headerView;
@property (nonatomic,assign) UIWebView *webView;
@property (nonatomic, readonly) NSString *pageTitle;

- (void) openURL:(NSURL*)url;
- (void) setWebView:(UIWebView *)wv; 

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol JMBrowserControllerDelegate <NSObject>

@end