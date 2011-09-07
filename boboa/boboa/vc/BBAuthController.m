//
//  BBAuthController.m
//  boboa
//
//  Created by Yanbo Wu on 9/7/11.
//

#import "BBAuthController.h"
#import <WebKit/WebKit.h>

@implementation BBAuthController


@synthesize window;

- (id)init
{
    self = [super init];
    if (self) {
        authorizer = [[BBAuthorizer sinaAuthorizer] retain];
        authorizer.delegate = self;

        NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
        [em setEventHandler:self 
                andSelector:@selector(getUrl:withReplyEvent:) 
              forEventClass:kInternetEventClass 
                 andEventID:kAEGetURL];
        NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
        LSSetDefaultHandlerForURLScheme((CFStringRef)@"boboa", (CFStringRef)bundleID);
    }
    
    return self;
}

- (void)dealloc
{
    [authorizer release];
    [window release];
    [super dealloc];
}

#pragma mark - actions

- (IBAction)auth:(id)sender
{
    [authorizer authorize];
}

- (IBAction)signup:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://weibo.com"]];
}

#pragma mark - delegates

-(void) didGetRequestToken:(OAToken *)token
{
    // remove all existing subviews
    NSArray *subviews = [[[window contentView] subviews] copy];
    for (NSView *subview in subviews) {
        [subview removeFromSuperview];
    }
    [subviews release];

    // add a single web view
    [window setFrame:NSMakeRect(window.frame.origin.x, window.frame.origin.y, 640, 375) display:YES animate:YES];
    WebView *authWebView = [[WebView alloc] initWithFrame:NSMakeRect(0, -20, 640, 375)];
    [[window contentView] addSubview:authWebView];
    [authWebView release];
    [authWebView setMainFrameURL:[NSString stringWithFormat:[authorizer authURL], token.key]];
}

-(void) didGetAccessToken:(OAToken *)token
{
    // simply close the window
    [window close];
}

-(void) getUrl:(NSAppleEventDescriptor *)event 
withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *urlStr = [[event paramDescriptorForKeyword:keyDirectObject] 
                        stringValue];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"BBVerified" object:urlStr]]; 
}


@end
