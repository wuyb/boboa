//
//  BBWeibo.m
//  boabo
//
//  Created by Yanbo Wu on 3/27/11.
//

#import "BBWeibo.h"

NSString *TWITTERFON_FORM_BOUNDARY = @"0194784892923";

@implementation BBWeibo

@synthesize delegate;

-(id) initWithAppKey:(NSString *)appKey
              Secret:(NSString *)secret
         accessToken:(NSString *)accessToken
        accessSecret:(NSString *)accessSecret
            delegate:(id<BBWeiboDelegate>)d
{
    if (appKey == nil || secret == nil || accessToken == nil || accessSecret == nil || d == nil) {
        [self release];
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        consumer = [[OAConsumer alloc] initWithKey:appKey secret:secret];
        token = [[OAToken alloc] initWithKey:accessToken secret:accessSecret];
        self.delegate = d;
        
        // read the configuration
        NSString *errorDesc = nil;
        NSPropertyListFormat format;
        NSString *plistPath;
        NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                  NSUserDomainMask, YES) objectAtIndex:0];
        plistPath = [rootPath stringByAppendingPathComponent:@"sinaweibo.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            plistPath = [[NSBundle mainBundle] pathForResource:@"sinaweibo" ofType:@"plist"];
        }
        NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
        conf = (NSDictionary *)[[NSPropertyListSerialization
                                 propertyListFromData:plistXML
                                 mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                 format:&format
                                 errorDescription:&errorDesc] retain];
        if (errorDesc) {
            // fatal error, just return nil, let the user determine what to do
            NSLog(@"Error reading plist: %@, format: %lu", errorDesc, format);
            [self release];
            return nil;
        }
        if (!conf) {
            [self release];
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc
{
    [conf release];
    [delegate release];
    [token release];
    [consumer release];
    [super dealloc];
}

// Fetches the data asynchronously
-(void) fetchDataFromUrl:(NSString *) url
          withParameters:(NSArray *) params
     didFinishedSelector:(SEL) didFinishedSelector
       didFailedSelector:(SEL) didFailedSelector
{
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:NULL
                                                          signatureProvider:[[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease]];
    [request setHTTPMethod:@"GET"];
    [request setParameters:params];
    [request prepare];
    
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:request
                                          delegate:delegate
                                          didFinishSelector:didFinishedSelector didFailSelector:didFailedSelector];
    [fetcher start];
    [request release];
}

-(void) postDataToUrl:(NSString *) url
       withParameters:(NSArray *) params
  didFinishedSelector:(SEL) didFinishedSelector
    didFailedSelector:(SEL) didFailedSelector
{
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:NULL
                                                          signatureProvider:[[[OAHMAC_SHA1SignatureProvider alloc] init] autorelease]];
    [request setHTTPMethod:@"POST"];
    [request setParameters:params];
    [request prepare];
    
    OAAsynchronousDataFetcher *fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:request
                                                                                          delegate:delegate
                                                                                 didFinishSelector:didFinishedSelector didFailSelector:didFailedSelector];
    
    [fetcher start];
    [request release];
}

-(NSArray *) prepareParametersWithSinceId:(long) sinceId count:(int)count
{
    NSMutableArray *parameters = nil;
    if (sinceId != -1 || count != -1) {
        parameters = [[[NSMutableArray alloc] init] autorelease];
        if (sinceId != -1) {
            [parameters addObject:[[[OARequestParameter alloc] initWithName:@"since_id"
                                                                      value:[NSString stringWithFormat:@"%ld", sinceId]] autorelease]];
        }
        if (count != -1) {
            [parameters addObject:[[[OARequestParameter alloc] initWithName:@"count"
                                                                      value:[NSString stringWithFormat:@"%d", count]] autorelease]];
        }
    }
    return parameters;
}

-(NSArray *) prepareParametersWithBeforeId:(long) sinceId count:(int)count
{
    NSMutableArray *parameters = nil;
    if (sinceId != -1 || count != -1) {
        parameters = [[[NSMutableArray alloc] init] autorelease];
        if (sinceId != -1) {
            [parameters addObject:[[[OARequestParameter alloc] initWithName:@"max_id"
                                                                      value:[NSString stringWithFormat:@"%ld", sinceId - 1]] autorelease]];
        }
        if (count != -1) {
            [parameters addObject:[[[OARequestParameter alloc] initWithName:@"count"
                                                                      value:[NSString stringWithFormat:@"%d", count]] autorelease]];
        }
    }
    return parameters;
}


-(void) getPublicTimeline
{
    [self getPublicTimeline:nil];
}

-(void) getPublicTimeline:(NSArray *)params
{
    [self fetchDataFromUrl:[conf objectForKey:@"public_timeline_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getPublicTimelineFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}


-(void) getFriendsTimeline
{
    [self getFriendsTimelineSince:-1 withCount:-1];
}

-(void) getFriendsTimelineSince:(long) sinceId withCount:(int) count
{
    [self getFriendsTimeline:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getFriendsTimelineBefore:(long) beforeId withCount:(int) count
{
    [self getFriendsTimeline:[self prepareParametersWithBeforeId:beforeId count:count]];
}

-(void) getFriendsTimeline:(NSArray *)params
{
    [self fetchDataFromUrl:[conf objectForKey:@"friends_timeline_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getFriendsTimelineFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getMyTimeline
{
    [self getMyTimelineSince:-1 withCount:-1];
}

-(void) getMyTimelineSince:(long) sinceId withCount:(int) count
{
    [self getMyTimeline:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getMyTimeline:(NSArray *)params
{
    [self getTimelineForUser:-1 withParameters:params];
}

-(void) getTimelineForUser:(long)id
{
    [self getTimelineForUser:id since:-1 withCount:-1];
}

-(void) getTimelineForUser:(long)id before:(long)beforeId withCount:(int)count
{
    [self getTimelineForUser:id withParameters:[self prepareParametersWithBeforeId:beforeId count:count]];
}

-(void) getTimelineForUser:(long)id since:(long)sinceId withCount:(int)count
{
    [self getTimelineForUser:id withParameters:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getTimelineForUser:(long)id withParameters:(NSArray *)params
{
    NSMutableArray *parameters = [NSMutableArray arrayWithArray:params];
    if (id != -1) {
        [parameters addObject:[[[OARequestParameter alloc] initWithName:@"user_id"
                                                                  value:[NSString stringWithFormat:@"%ld", id]] autorelease]];
    }
    [self fetchDataFromUrl:[conf objectForKey:@"user_timeline_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getUserTimelineFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getUnreadSince:(long)sinceId
{
    NSMutableArray *parameters = [NSMutableArray array];
    [parameters addObject:[[[OARequestParameter alloc] initWithName:@"with_new_status"
                                                              value:[NSString stringWithFormat:@"%d", 1]] autorelease]];
    if (sinceId != -1) {
        [parameters addObject:[[[OARequestParameter alloc] initWithName:@"sinceId"
                                                                  value:[NSString stringWithFormat:@"%ld", sinceId]] autorelease]];
    }
    
    [self fetchDataFromUrl:[conf objectForKey:@"unread_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getUnreadFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getMentionedMe
{
    [self getMentionedMeSince:-1 withCount:-1];
}

-(void) getMentionedMeSince:(long)sinceId withCount:(int)count
{
    [self getMentionedMe:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getMentionedMeBefore:(long)beforeId withCount:(int)count
{
    [self getMentionedMe:[self prepareParametersWithBeforeId:beforeId count:count]];
}

-(void) getMentionedMe:(NSArray *)parameters
{
    [self fetchDataFromUrl:[conf objectForKey:@"mentioned_me_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getMentionedMeFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getComments
{
    [self getCommentsPage:1 withCount:-1];
}

-(void) getCommentsPage:(int)page withCount:(int)count;
{
    NSMutableArray *params = [NSMutableArray array];
    [params addObject:[[[OARequestParameter alloc] initWithName:@"page"
                                                          value:[NSString stringWithFormat:@"%d", page]] autorelease]];
    [self getComments:params];
}

-(void) getComments:(NSArray *)parameters
{
    [self fetchDataFromUrl:[conf objectForKey:@"comments_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getCommentsFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getCommentsByMe
{
    [self getCommentsByMeSince:-1 withCount:-1];
}

-(void) getCommentsByMeSince:(long)sinceId withCount:(int)count
{
    [self getCommentsByMe:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getCommentsByMe:(NSArray *)parameters
{
    [self fetchDataFromUrl:[conf objectForKey:@"comments_by_me_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getCommentsByMeFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getCommentsToMe
{
    [self getCommentsToMeSince:-1 withCount:-1];
}

-(void) getCommentsToMeBefore:(long)beforeId withCount:(int)count
{
    [self getCommentsToMe:[self prepareParametersWithBeforeId:beforeId count:count]];
}

-(void) getCommentsToMeSince:(long)sinceId withCount:(int)count
{
    [self getCommentsToMe:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getCommentsToMe:(NSArray *)parameters
{
    [self fetchDataFromUrl:[conf objectForKey:@"comments_to_me_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getCommentsToMeFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getCommentsToStatus:(long)id page:(int)page
{
    NSMutableArray *params = [NSMutableArray array];
    [params addObject:[[[OARequestParameter alloc] initWithName:@"page"
                                                          value:[NSString stringWithFormat:@"%d", page]] autorelease]];
    [self getCommentsToStatus:id withParameters:params];
}

-(void) getCommentsToStatus:(long)id withParameters:(NSArray *)parameters
{
    NSMutableArray *params = [NSMutableArray arrayWithArray:parameters];
    [params addObject:[[[OARequestParameter alloc] initWithName:@"id"
                                                          value:[NSString stringWithFormat:@"%ld", id]] autorelease]];
    [self fetchDataFromUrl:[conf objectForKey:@"comments_to_status_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getCommentsToStatusFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getCounts:(NSArray *) ids
{
    NSMutableString * string = [NSMutableString string];
    int i = 0;
    for (NSString * id in ids) {
        [string appendFormat:@"%@", id];
        if (i != [ids count] - 1) {
            [string appendString:@","];
        }
    }
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"ids"
                                                                    value:[NSString stringWithFormat:@"%@", string]] autorelease];
    NSArray *parameters = [NSArray arrayWithObjects:param, nil];
    [self fetchDataFromUrl:[conf objectForKey:@"counts_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getCountsFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getRepostTimelineFor:(long)id
{
    [self getRepostTimelineFor:id since:-1 withCount:-1];
}

-(void) getRepostTimelineFor:(long)id since:(long)sinceId withCount:(int)count
{
    [self getRepostTimelineFor:id withParameters:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getRepostTimelineFor:(long)id withParameters:(NSArray *)parameters
{
    NSMutableArray *params = [NSMutableArray arrayWithArray:parameters];
    [params addObject:[[[OARequestParameter alloc] initWithName:@"id"
                                                          value:[NSString stringWithFormat:@"%ld", id]] autorelease]];
    [self fetchDataFromUrl:[conf objectForKey:@"repost_timeline_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getRepostTimelineFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
    
}

-(void) getRepostTimelineBy:(long)id
{
    [self getRepostTimelineBy:id since:-1 withCount:-1];
}

-(void) getRepostTimelineBy:(long)id since:(long)sinceId withCount:(int)count
{
    [self getRepostTimelineBy:id withParameters:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getRepostTimelineBy:(long)id withParameters:(NSArray *)parameters
{
    NSMutableArray *params = [NSMutableArray arrayWithArray:parameters];
    [params addObject:[[[OARequestParameter alloc] initWithName:@"id"
                                                          value:[NSString stringWithFormat:@"%ld", id]] autorelease]];
    [self fetchDataFromUrl:[conf objectForKey:@"repost_timeline_by_user_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getRepostTimelineByUserFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) resetCountForType:(int)type
{
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"type"
                                                                    value:[NSString stringWithFormat:@"%d", type]] autorelease];
    NSArray *parameters = [NSArray arrayWithObjects:param, nil];
    [self postDataToUrl: [conf objectForKey:@"reset_count_url"]
         withParameters:parameters
    didFinishedSelector:NSSelectorFromString(@"resetCountFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getEmotionsForType:(NSString *)type
{
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"type"
                                                                    value:[NSString stringWithFormat:@"%@", type]] autorelease];
    NSArray *parameters = [NSArray arrayWithObjects:param, nil];
    [self postDataToUrl:[conf objectForKey:@"emotions_url"]
         withParameters:parameters
    didFinishedSelector:NSSelectorFromString(@"getEmotionsFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) destroy:(long)id
{
    [self postDataToUrl:[NSString stringWithFormat:[conf objectForKey:@"destroy_url"], id]
         withParameters:nil
    didFinishedSelector:NSSelectorFromString(@"destroyFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getFavoirtesWithParameters:(NSArray*)parameters
{
}

-(void) getFavoritesForPage:(NSUInteger)pageId
{
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"page"
                                                                    value:[NSString stringWithFormat:@"%d", pageId]] autorelease];
    NSArray *parameters = [NSArray arrayWithObjects:param, nil];
    
    [self fetchDataFromUrl:[conf objectForKey:@"favorites_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getFavoritesFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
    
}


-(void) addToFavorite:(long)id
{
    [self postDataToUrl:[NSString stringWithFormat:[conf objectForKey:@"favorite_create_url"], id]
         withParameters:nil
    didFinishedSelector:NSSelectorFromString(@"createFavoriteFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) removeFromFavorite:(long)id
{
    [self postDataToUrl:[NSString stringWithFormat:[conf objectForKey:@"favorite_destroy_url"], id]
         withParameters:nil
    didFinishedSelector:NSSelectorFromString(@"removeFavoriteFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

- (NSString*) nameValString: (NSDictionary*) dict {
	NSArray* keys = [dict allKeys];
	NSString* result = [NSString string];
	int i;
	for (i = 0; i < [keys count]; i++) {
        result = [result stringByAppendingString:
                  [@"--" stringByAppendingString:
                   [TWITTERFON_FORM_BOUNDARY stringByAppendingString:
                    [@"\r\nContent-Disposition: form-data; name=\"" stringByAppendingString:
                     [[keys objectAtIndex: i] stringByAppendingString:
                      [@"\"\r\n\r\n" stringByAppendingString:
                       [[dict valueForKey: [keys objectAtIndex: i]] stringByAppendingString: @"\r\n"]]]]]]];
	}
	
	return result;
}

- (NSString *)_encodeString:(NSString *)string
{
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, 
																		   (CFStringRef)string, 
																		   NULL, 
																		   (CFStringRef)@";/?:@&=$+{}<>,",
																		   kCFStringEncodingUTF8);
    return [result autorelease];
}

- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed
{
    // Append base if specified.
    NSMutableString *str = [NSMutableString stringWithCapacity:0];
    if (base) {
        [str appendString:base];
    }
    
    // Append each name-value pair.
    if (params) {
        int i;
        NSArray *names = [params allKeys];
        for (i = 0; i < [names count]; i++) {
            if (i == 0 && prefixed) {
                [str appendString:@"?"];
            } else if (i > 0) {
                [str appendString:@"&"];
            }
            NSString *name = [names objectAtIndex:i];
            [str appendString:[NSString stringWithFormat:@"%@=%@", 
							   name, [self _encodeString:[params objectForKey:name]]]];
        }
    }
    
    return str;
}

- (NSString *)getURL:(NSString *)path 
	 queryParameters:(NSMutableDictionary*)params {
    NSString* fullPath = path;
	if (params) {
        fullPath = [self _queryStringWithBase:fullPath parameters:params prefixed:YES];
    }
	return fullPath;
}

-(void) post:(NSString *)text withImage:(NSString *)imagePath
{
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
						 text, @"status",
						 @"3024838837", @"source",
                         nil];
    
    NSString *param = [self nameValString:dic];
    NSString *footer = [NSString stringWithFormat:@"\r\n--%@--\r\n", TWITTERFON_FORM_BOUNDARY];
    
    param = [param stringByAppendingString:[NSString stringWithFormat:@"--%@\r\n", TWITTERFON_FORM_BOUNDARY]];
    param = [param stringByAppendingString:@"Content-Disposition: form-data; name=\"pic\";filename=\"image.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"];
	
    NSMutableData *data = [NSMutableData data];
    [data appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[[NSData alloc] initWithContentsOfFile:imagePath]];
    [data appendData:[footer dataUsingEncoding:NSUTF8StringEncoding]];
    
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
	[params setObject:@"3024838837" forKey:@"source"];
	[params setObject:text forKey:@"status"];
    
    NSString *path = [conf objectForKey:@"upload_url"];
    path = [self getURL:path queryParameters:params];
    NSString *URL = (NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)path, (CFStringRef)@"%", NULL, kCFStringEncodingUTF8);
    [URL autorelease];
	NSURL *finalURL = [NSURL URLWithString:URL];
	NSMutableURLRequest* req;
	OAMutableURLRequest* oaReq;
    oaReq = [[[OAMutableURLRequest alloc] initWithURL:finalURL
                                             consumer:consumer 
                                                token:token 
                                                realm: nil
                                    signatureProvider:nil] autorelease];
    req = oaReq;
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", TWITTERFON_FORM_BOUNDARY];
    [req setHTTPShouldHandleCookies:NO];
    [req setHTTPMethod:@"POST"];
    [req setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    [req setHTTPBody:data];
	[oaReq prepare];
    
    OAAsynchronousDataFetcher * fetcher = [OAAsynchronousDataFetcher asynchronousFetcherWithRequest:oaReq 
                                                                                       delegate:delegate
                                                                              didFinishSelector:@selector(postFinished:withData:)
                                                                                didFailSelector:@selector(failed:withError:)];
    
    [fetcher start];
    
}


-(void) post:(NSString *)text
{
    [self post:text withParameters:nil];
}

-(void) post:(NSString *)text withParameters:(NSArray *)parameters
{
    NSMutableArray *params = [NSMutableArray arrayWithArray:parameters];
    [params addObject:[[[OARequestParameter alloc] initWithName:@"status"
                                                          value:[NSString stringWithFormat:@"%@", text]] autorelease]];
    [self postDataToUrl:[conf objectForKey:@"post_url"]
         withParameters:params
    didFinishedSelector:NSSelectorFromString(@"postFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) repost:(NSString *) text toPost:(long)id
{
    [self repost:text toPost:id withParameters:nil];
}

-(void) repost:(NSString *) text toPost:(long)id withParameters:(NSArray *)parameters
{
    NSMutableArray *params = [NSMutableArray arrayWithArray:parameters];
    if (text != nil)
    {
        [params addObject:[[[OARequestParameter alloc] initWithName:@"status"
                                                              value:[NSString stringWithFormat:@"%@", text]] autorelease]];
    }
    [params addObject:[[[OARequestParameter alloc] initWithName:@"id"
                                                          value:[NSString stringWithFormat:@"%ld", id]] autorelease]];
    [self postDataToUrl:[conf objectForKey:@"repost_url"]
         withParameters:params
    didFinishedSelector:NSSelectorFromString(@"repostFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) comment:(NSString *) text toPost:(long)id
{
    [self comment:text toPost:id withParameters:nil];
}

-(void) comment:(NSString *) text toPost:(long)id repost:(BOOL)repost
{
    if (repost) {
        NSMutableArray *params = [NSMutableArray array];
        OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"is_comment"
                                                                        value:@"1"] autorelease];
        [params addObject:param];
        [self repost:text toPost:id withParameters:params];
    } else {
        [self comment:text toPost:id withParameters:nil];
    }
}

-(void) comment:(NSString *) text toPost:(long)id comment:(long)cid
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"cid"
                                                                    value:[NSString stringWithFormat:@"%ld", cid]] autorelease];
    [params addObject:param];
    [self comment:text toPost:id withParameters:params];
}

-(void) comment:(NSString *) text toPost:(long)id withParameters:(NSArray *)parameters
{
    NSMutableArray *params = [NSMutableArray arrayWithArray:parameters];
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"id"
                                                                    value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    [params addObject:param];
    param = [[[OARequestParameter alloc] initWithName:@"comment"
                                                value:[NSString stringWithFormat:@"%@", text]] autorelease];
    [params addObject:param];
    [self postDataToUrl:[conf objectForKey:@"comment_url"]
         withParameters:params
    didFinishedSelector:NSSelectorFromString(@"commentFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) destroyComment:(long)id
{
    [self postDataToUrl:[NSString stringWithFormat:[conf objectForKey:@"destroy_comment_url"], id]
         withParameters:nil
    didFinishedSelector:NSSelectorFromString(@"destroyCommentFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) destroyComments:(NSArray *)ids
{
    NSMutableString * string = [NSMutableString string];
    int i = 0;
    for (NSNumber * id in ids) {
        [string appendFormat:@"%@", id];
        if (i != [ids count] - 1) {
            [string appendString:@","];
        }
    }
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"ids"
                                                                    value:[NSString stringWithFormat:@"%@", string]] autorelease];
    NSArray *parameters = [NSArray arrayWithObjects:param, nil];
    [self postDataToUrl:[conf objectForKey:@"destroy_comments_url"]
         withParameters:parameters
    didFinishedSelector:NSSelectorFromString(@"destroyCommentsFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) reply:(NSString *) text toPost:(long)id andComment:(long)cid
{
    OARequestParameter *cidParam = [[[OARequestParameter alloc] initWithName:@"cid"
                                                                       value:[NSString stringWithFormat:@"%ld", cid]] autorelease];
    OARequestParameter *pidParam = [[[OARequestParameter alloc] initWithName:@"id"
                                                                       value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    OARequestParameter *textParam = [[[OARequestParameter alloc] initWithName:@"comment"
                                                                        value:[NSString stringWithFormat:@"%@", text]] autorelease];
    NSMutableArray *parameters = [NSMutableArray arrayWithObjects:cidParam, pidParam, textParam, nil];
    [self postDataToUrl:[conf objectForKey:@"reply_url"]
         withParameters:parameters
    didFinishedSelector:NSSelectorFromString(@"replyFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) showUser:(long) id
{
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    NSMutableArray *parameters = [NSMutableArray arrayWithObjects:idParam, nil];
    [self fetchDataFromUrl:[conf objectForKey:@"show_user_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"showUserFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) showUserByScreenName:(NSString*) screenName
{
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"screen_name"
                                                                      value:screenName] autorelease];
    NSMutableArray *parameters = [NSMutableArray arrayWithObjects:idParam, nil];
    [self fetchDataFromUrl:[conf objectForKey:@"show_user_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"showUserFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getFollowees:(long) id withCursor:(int)nextCursor
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"cursor"
                                                                      value:[NSString stringWithFormat:@"%d", nextCursor]] autorelease];
    [params addObject:idParam];
    [self getFollowees:id withParameters:params];
}

-(void) getFollowees:(long) id withCursor:(int)nextCursor count:(int)count
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"cursor"
                                                                      value:[NSString stringWithFormat:@"%d", nextCursor]] autorelease];
    [params addObject:idParam];
    idParam = [[[OARequestParameter alloc] initWithName:@"count"
                                                  value:[NSString stringWithFormat:@"%d", count]] autorelease];
    [params addObject:idParam];
    [self getFollowees:id withParameters:params];
}


-(void) getFollowees:(long) id withParameters:(NSArray *)parameters
{
    NSMutableArray *params = [NSMutableArray arrayWithArray:parameters];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    [params addObject:idParam];
    [self fetchDataFromUrl:[conf objectForKey:@"get_followees_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getFolloweesFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getFollowers:(long) id withCursor:(int)nextCursor
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"cursor"
                                                                      value:[NSString stringWithFormat:@"%d", nextCursor]] autorelease];
    [params addObject:idParam];
    [self getFollowers:id withParameters:params];
}

-(void) getFollowers:(long) id withParameters:(NSArray *)parameters
{
    NSMutableArray *params = [NSMutableArray arrayWithArray:parameters];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    [params addObject:idParam];
    [self fetchDataFromUrl:[conf objectForKey:@"get_followers_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getFollowersFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getDirectMessage
{
    [self getDirectMessageSince:-1 withCount:-1];
}

-(void) getDirectMessageSince:(long)sinceId withCount:(int)count
{
    [self getDirectMessageWithParameters:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getDirectMessageBefore:(long)beforeId withCount:(int)count
{
    [self getDirectMessageWithParameters:[self prepareParametersWithBeforeId:beforeId count:count]];
}


-(void) getDirectMessageWithParameters:(NSArray *)params
{
    [self fetchDataFromUrl:[conf objectForKey:@"get_direct_message_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getDirectMessageFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getSentDirectMessage
{
    [self getSentDirectMessageSince:-1 withCount:-1];
}

-(void) getSentDirectMessageSince:(long)sinceId withCount:(int)count
{
    [self getSentDirectMessageWithParameters:[self prepareParametersWithSinceId:sinceId count:count]];
}

-(void) getSentDirectMessageWithParameters:(NSArray *)parameters
{
    [self fetchDataFromUrl:[conf objectForKey:@"get_sent_direct_message_url"]
            withParameters:parameters
       didFinishedSelector:NSSelectorFromString(@"getSentDirectMessageFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) sendDirectMessage:(NSString *) text to:(long)id
{
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    OARequestParameter *uidParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                       value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    OARequestParameter *textParam = [[[OARequestParameter alloc] initWithName:@"text"
                                                                        value:[NSString stringWithFormat:@"%@", text]] autorelease];
    NSMutableArray *parameters = [NSMutableArray arrayWithObjects:idParam, uidParam, textParam, nil];
    [self postDataToUrl:[conf objectForKey:@"send_direct_message_url"]
         withParameters:parameters
    didFinishedSelector:NSSelectorFromString(@"sendDirectMessageFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
    
}

-(void) destroyDirectMessage:(long)id
{
    [self postDataToUrl:[NSString stringWithFormat:[conf objectForKey:@"destroy_direct_message_url"], id]
         withParameters:nil
    didFinishedSelector:NSSelectorFromString(@"destroyDirectMessageFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) destroyDirectMessages:(NSArray *)ids
{
    NSMutableString * string = [NSMutableString string];
    int i = 0;
    for (NSNumber * id in ids) {
        [string appendFormat:@"%@", id];
        if (i != [ids count] - 1) {
            [string appendString:@","];
        }
    }
    OARequestParameter *param = [[[OARequestParameter alloc] initWithName:@"ids"
                                                                    value:[NSString stringWithFormat:@"%@", string]] autorelease];
    NSArray *parameters = [NSArray arrayWithObjects:param, nil];
    [self postDataToUrl:[conf objectForKey:@"destroy_direct_messages_url"]
         withParameters:parameters
    didFinishedSelector:NSSelectorFromString(@"destroyDirectMessagesFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) follow:(long)id
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    [params addObject:idParam];
    [self postDataToUrl:[conf objectForKey:@"follow_url"]
         withParameters:params
    didFinishedSelector:NSSelectorFromString(@"followFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
    
}

-(void) unfollow:(long)id
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    [params addObject:idParam];
    [self postDataToUrl:[conf objectForKey:@"unfollow_url"]
         withParameters:params
    didFinishedSelector:NSSelectorFromString(@"unfollowFinished:withData:")
      didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}


-(void) showRelationship:(long)id
{
    [self showRelationshipBetween:-1 and:id];
}

-(void) showRelationshipBetween:(long)aid and:(long)bid
{
    NSMutableArray *params = [NSMutableArray array];
    if (aid != -1) {
        OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"source_id"
                                                                          value:[NSString stringWithFormat:@"%ld", aid]] autorelease];
        [params addObject:idParam];
    }
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"target_id"
                                                                      value:[NSString stringWithFormat:@"%ld", bid]] autorelease];
    [params addObject:idParam];
    
    [self fetchDataFromUrl:[conf objectForKey:@"show_relationship_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"showRelationshipFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) block:(long)id
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    [params addObject:idParam];
    [self fetchDataFromUrl:[conf objectForKey:@"block_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"blockFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) unblock:(long)id
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    [params addObject:idParam];
    [self fetchDataFromUrl:[conf objectForKey:@"unblock_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"unblockFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) isBlocked:(long)id
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"user_id"
                                                                      value:[NSString stringWithFormat:@"%ld", id]] autorelease];
    [params addObject:idParam];
    [self fetchDataFromUrl:[conf objectForKey:@"check_block_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"checkBlockFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getBlockList
{
    [self fetchDataFromUrl:[conf objectForKey:@"get_block_list_url"]
            withParameters:nil
       didFinishedSelector:NSSelectorFromString(@"getBlockListFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) verify
{
    [self fetchDataFromUrl:[conf objectForKey:@"verify_url"]
            withParameters:nil
       didFinishedSelector:NSSelectorFromString(@"verifyFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getRateLimitStatus
{
    [self fetchDataFromUrl:[conf objectForKey:@"rate_limit_url"]
            withParameters:nil
       didFinishedSelector:NSSelectorFromString(@"getRateLimitStatusFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getTopic:(BB_TOPIC_TIME_FRAME)ttf
{
    NSString *urlFormat = [conf objectForKey:@"get_topics_url"];
    NSString *ttfName = nil;
    if (ttf == BB_TOPIC_TIME_FRAME_DAILY) {
        ttfName = @"daily";
    } else if (ttf == BB_TOPIC_TIME_FRAME_HOURLY) {
        ttfName = @"hourly";
    } else if (ttf == BB_TOPIC_TIME_FRAME_WEEKLY) {
        ttfName = @"weekly";
    }
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"base_app"
                                                                      value:@"0"] autorelease];
    [params addObject:idParam];
    [self fetchDataFromUrl:[NSString stringWithFormat:urlFormat, ttfName]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getTopicsFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

-(void) getStatusesForTopic:(NSString *)topic
{
    NSMutableArray *params = [NSMutableArray array];
    OARequestParameter *idParam = [[[OARequestParameter alloc] initWithName:@"trend_name"
                                                                      value:topic] autorelease];
    [params addObject:idParam];
    [self fetchDataFromUrl:[conf objectForKey:@"get_statuses_for_topic_url"]
            withParameters:params
       didFinishedSelector:NSSelectorFromString(@"getStatusesForTopicFinished:withData:")
         didFailedSelector:NSSelectorFromString(@"failed:withError:")
     ];
}

@end
