//
//  JMBrowserController.m
//  CodePlex
//
//  Created by Jake Marsh on 9/26/10.
//  Copyright 2010 Rubber Duck Software. All rights reserved.
//

#import "JMBrowserController.h"
#import "UIToolbar+Additions.h"
#import "UIView+Additions.h"

#define TOOLBAR_HEIGHT 44

#define ToolbarNavigationFrame() CGRectMake(0, 0, [UIScreen mainScreen].applicationFrame.size.width, [UIScreen mainScreen].applicationFrame.size.height - TOOLBAR_HEIGHT)

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation JMBrowserController

@synthesize delegate = _delegate, headerView = _headerView, webView = _webView;

///////////////////////////////////////////////////////////////////////////////////////////////////
// private

- (void) backAction {
	[_webView goBack];
}
- (void) forwardAction {
	[_webView goForward];
}
- (void) refreshAction {
	[_webView reload];
}
- (void) stopAction {
	[_webView stopLoading];
}
- (void) shareAction {
	UIActionSheet* sheet = [[[UIActionSheet alloc] initWithTitle:@"" delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Cancel", @"") destructiveButtonTitle:nil
											   otherButtonTitles:NSLocalizedString(@"Open in Safari", @""), NSLocalizedString(@"Mail Link to This Page", @""), nil] autorelease];
	[sheet showInView:self.view];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id) init {
	if (self = [super init]) {
		_delegate = nil;
		_webView = nil;
		_toolbar = nil;
		_headerView = nil;
		_backButton = nil;
		_forwardButton = nil;
		_stopButton = nil;
		_refreshButton = nil;
	}
	
	return self;
}

- (void) dealloc {
	[_headerView release];
	[super dealloc];
	[_webView release];
	_webView = nil;
	[_toolbar release];
	_toolbar = nil;
	[_backButton release];
	_backButton = nil;
	[_forwardButton release];
	_forwardButton = nil;
	[_refreshButton release];
	_refreshButton = nil;
	[_stopButton release];
	_stopButton = nil;
	[_activityItem release];
	_activityItem = nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void) loadView {  
	[super loadView];
  
	self.hidesBottomBarWhenPushed = YES;

	_webView = [[UIWebView alloc] initWithFrame:ToolbarNavigationFrame()];
	_webView.delegate = self;
	_webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_webView.scalesPageToFit = YES;

	[self.view addSubview:_webView];

	UIActivityIndicatorView* spinner = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
	[spinner startAnimating];
	_activityItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

	_backButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"JMBrowserController-backIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
	_backButton.tag = 2;
	_backButton.enabled = NO;

	_forwardButton = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed:@"JMBrowserController-forwardIcon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(forwardAction)];
	_forwardButton.tag = 1;
	_forwardButton.enabled = NO;
	
	_refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshAction)];
	_refreshButton.tag = 3;
	
	_stopButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopAction)];
	_stopButton.tag = 3;
	
	UIBarButtonItem* actionButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction)] autorelease];

	UIBarItem* space = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];

	_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
	_toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	_toolbar.barStyle = UIBarStyleDefault;
	//_toolbar.tintColor = [UIColor colorWithHexString:@"b8babc"];
	_toolbar.items = [NSArray arrayWithObjects:_backButton, space, _forwardButton, space, _refreshButton, space, actionButton, nil];

	[self.view addSubview:_toolbar];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIWebViewDelegate

- (BOOL) webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];
	return YES;
}
- (void) webViewDidStartLoad:(UIWebView*)webView {
	self.title = NSLocalizedString(@"Loading...", @"");
	//self.navigationItem.titleView = [UILabel titleLabelWithTitle:self.title];
	self.navigationItem.rightBarButtonItem = _activityItem;

	[_toolbar replaceItemWithTag:3 withItem:_stopButton];

	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];
}
- (void) webViewDidFinishLoad:(UIWebView*)webView {
	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];

	self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	//self.navigationItem.titleView = [UILabel titleLabelWithTitle:self.title];

	self.navigationItem.rightBarButtonItem = nil;
	[_toolbar replaceItemWithTag:3 withItem:_refreshButton];
	[_webView canGoBack];
}
- (void) webView:(UIWebView*)webView didFailLoadWithError:(NSError*)error {
	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];

	[self webViewDidFinishLoad:webView];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIActionSheetDelegate

- (void) actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[[UIApplication sharedApplication] openURL:_webView.request.URL];
	} else if(buttonIndex == 1) {
		//Mail Link to This Page

		MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
		vc.mailComposeDelegate = self;

		[vc setSubject:[_webView stringByEvaluatingJavaScriptFromString:@"document.title"]];
		[vc setMessageBody:_webView.request.URL.absoluteString isHTML:NO];

		[self presentModalViewController:vc animated:YES];

		[vc release];
	}
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	[self dismissModalViewControllerAnimated:YES];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

- (NSString *) pageTitle {
	return [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}
- (NSURL*) url {
	return _webView.request.URL;
}
- (void) setHeaderView:(UIView*)headerView {
	if (headerView != _headerView) {
		BOOL addingHeader = !_headerView && headerView;
		BOOL removingHeader = _headerView && !headerView;

		[_headerView removeFromSuperview];
		[_headerView release];
		_headerView = [headerView retain];
		_headerView.frame = CGRectMake(0, 0, _webView.width, _headerView.height);

		self.view;
		UIView* scroller = [_webView firstViewOfClass:NSClassFromString(@"UIScroller")];
		UIView* docView = [scroller firstViewOfClass:NSClassFromString(@"UIWebDocumentView")];
		[scroller addSubview:_headerView];

		if (addingHeader) {
			docView.top += headerView.height;
			docView.height -= headerView.height; 
		} else if (removingHeader) {
			docView.top -= headerView.height;
			docView.height += headerView.height; 
		}
	}
}
- (void) openURL:(NSURL*)url {
	self.view;
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
	[_webView loadRequest:request];
}
- (void) setWebView:(UIWebView *)wv {
	wv.frame = ToolbarNavigationFrame();
	wv.delegate = self;
	wv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	wv.scalesPageToFit = YES;
	_webView = wv;

	self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	//self.navigationItem.titleView = [UILabel titleLabelWithTitle:self.title];

	[_webView setNeedsLayout];
	[_webView setNeedsDisplay];
	
	_backButton.enabled = [_webView canGoBack];
	_forwardButton.enabled = [_webView canGoForward];
}

@end