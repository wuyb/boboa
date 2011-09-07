//
//  BBAuthorizer.m
// 
//

#import "BBAuthorizer.h"
#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OAAsynchronousDataFetcher.h"
#import "OAServiceTicket.h"
#import "SSKeychain.h"

@interface BBAuthorizer (Private)
-(BOOL)authorizeWithKeychain;
-(void)getRequestToken;
-(void)getAccessToken:(OAToken *)requestToken;
-(void)didReceiveVerifier:(NSNotification *)notification;
@end

@implementation BBAuthorizer

@synthesize delegate;

+(BBAuthorizer *) sinaAuthorizer
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"http://api.t.sina.com.cn/oauth/request_token", @"oauthGetRequestTokenURL",
                          @"http://api.t.sina.com.cn/oauth/authorize?oauth_token=%@", @"oauthUserAuthorizeURL",
                          @"http://api.t.sina.com.cn/oauth/access_token", @"oauthGetAccessTokenURL",
                          @"boboa://callback-sina", @"oauthCallbackURL",
                          nil];
    return [[[BBAuthorizer alloc] initWithKey:SINA_KEY secret:SINA_SECRET keychain:SINA_KEYCHAIN oauthURLs:dict] autorelease];
}

+(BBAuthorizer *) qqAuthorizer
{
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                          @"https://open.t.qq.com/cgi-bin/request_token", @"oauthGetRequestTokenURL",
                          @"https://open.t.qq.com/cgi-bin/authorize?oauth_token=%@", @"oauthUserAuthorizeURL",
                          @"https://open.t.qq.com/cgi-bin/access_token", @"oauthGetAccessTokenURL",
                          @"boboa://callback-qq", @"oauthCallbackURL",
                          nil];
    return [[[BBAuthorizer alloc] initWithKey:QQ_KEY secret:QQ_SECRET keychain:QQ_KEYCHAIN oauthURLs:dict] autorelease];
}


-(id) initWithKey:(NSString *)aKey
           secret:(NSString *)aSecret
         keychain:(NSString *)aKeychain
        oauthURLs:(NSDictionary *)map
{
    self = [super init];
    if (self) {
        appKey = [aKey copy];
        appSecret = [aSecret copy];
        keychainName = [aKeychain copy];
        oauthURLs = [map retain];
    }
    return self;
}

-(void)authorize
{
    [self getRequestToken];
}

-(OAToken *)accessToken
{
    NSArray *accounts = [SSKeychain accountsForService:@"boboa"];
    if ([accounts count] > 0) {
        // only one account permitted
        NSDictionary *account = [accounts objectAtIndex:0];
        NSString *secret = [SSKeychain passwordForService:@"boboa" account:[account objectForKey:(id)kSecAttrAccount]];
        if ([secret length] > 0) {
            OAToken *token = [[OAToken alloc] initWithKey:[account objectForKey:(id)kSecAttrAccount] secret:secret];
            return [token autorelease];
        }
    }
        
    return nil;
}

-(BOOL)isAuthorized
{
    NSArray *accounts = [SSKeychain accountsForService:@"boboa"];
    if ([accounts count] > 0) {
        // only one account permitted
        NSDictionary *account = [accounts objectAtIndex:0];
        NSString *secret = [SSKeychain passwordForService:@"boboa" account:[account objectForKey:(id)kSecAttrAccount]];
        if ([secret length] > 0) {
            return YES;
        }
    }
    return NO;
}

-(void) endSession
{
    NSArray *accounts = [SSKeychain accountsForService:@"boboa"];
    for (NSString *account in accounts) {
        [SSKeychain deletePasswordForService:@"boboa" account:account];
    }
}


-(void)getRequestToken
{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:appKey
                                                    secret:appSecret];
    NSURL *url = [NSURL URLWithString:[oauthURLs objectForKey:@"oauthGetRequestTokenURL"]];
    OAMutableURLRequest *request
    = [[OAMutableURLRequest alloc] initWithURL:url
                                      consumer:consumer
                                         token:NULL
                                         realm:NULL
                             signatureProvider:[[OAHMAC_SHA1SignatureProvider alloc] init]];
    
    [request setHTTPMethod:@"GET"];
    OARequestParameter *authCallback
    = [[[OARequestParameter alloc] initWithName:@"oauth_callback"
                                          value:[oauthURLs objectForKey:@"oauthCallbackURL"]] autorelease];
    NSArray *parameters = [NSArray arrayWithObjects:authCallback, nil];
    [request setParameters:parameters];
    
    OAAsynchronousDataFetcher *fetcher
    = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:request
                                                       delegate:self
                                              didFinishSelector:@selector(didGetRequestToken:withData:)
                                                didFailSelector:@selector(failedGetRequestToken:withData:)];
    [fetcher start];
    [request release];
}

-(void)getAccessToken:(OAToken *)token
{
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:appKey
                                                    secret:appSecret];
    NSURL *url = [NSURL URLWithString:[oauthURLs objectForKey:@"oauthGetAccessTokenURL"]];
    OAMutableURLRequest *request
    = [[OAMutableURLRequest alloc] initWithURL:url
                                      consumer:consumer
                                         token:requestToken
                                         realm:NULL
                             signatureProvider:[[OAHMAC_SHA1SignatureProvider alloc] init]];
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"oauth_verifier" value:[token pin]] autorelease];
    NSArray *parameters = [NSArray arrayWithObjects:param, nil];
    [request setParameters:parameters];
    [request setHTTPMethod:@"GET"];
    
    OAAsynchronousDataFetcher *fetcher
    = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:request
                                                       delegate:self
                                              didFinishSelector:@selector(didGetAccessToken:withData:)
                                                didFailSelector:@selector(failedGetAccessToken:withData:)];
    [fetcher start];
    [request release];
}
-(NSString *) authURL
{
    return [oauthURLs objectForKey:@"oauthUserAuthorizeURL"];
}

#pragma mark - delegates

-(void) didReceiveVerifier:(NSNotification *)notification
{
    NSString *urlStr = notification.object;
    NSRange paramStartIndex = [urlStr rangeOfString:@"?"];
    if (paramStartIndex.location != NSNotFound) {
        urlStr = [urlStr substringFromIndex:paramStartIndex.location + 1];
    }
    OAToken *token = [[OAToken alloc] initWithHTTPResponseBody:urlStr];
    [self getAccessToken:token];
}

-(void)didGetRequestToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveVerifier:)
                                                 name:@"BBVerified" object:nil]; 
    
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    
    requestToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    
    if ([delegate respondsToSelector:@selector(didGetRequestToken:)]) {
        [delegate didGetRequestToken:requestToken];
    } else {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:[oauthURLs objectForKey:@"oauthUserAuthorizeURL"], requestToken.key]]];
    }
}

-(void)failedGetRequestToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
    NSLog(@"Failure with issue %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    [delegate failedGetRequestToken];
}


-(void)didGetAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BBVerified" object:nil];
    
    NSString *responseBody = [[NSString alloc] initWithData:data
                                                   encoding:NSUTF8StringEncoding];
    OAToken *accessToken = [[OAToken alloc] initWithHTTPResponseBody:responseBody];
    [SSKeychain setPassword:accessToken.secret forService:@"boboa" account:accessToken.key];
    
    [delegate didGetAccessToken:accessToken];
}

-(void)failedGetAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
    NSLog(@"Failure with issue %@", [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    [delegate failedGetAccessToken];
}

@end
