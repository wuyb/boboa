//
//  BBWeiboTest.m
//  boboa
//
//  Created by Yanbo Wu on 8/24/11.
//

#import "BBWeiboTest.h"
#import "BBParser.h"
#import "BBStatus.h"
#import "BBComment.h"
#import "JSONKit.h"

// The app key and secret here is for boboa.opensource
NSString *appKey = @"2331956207";
NSString *secret = @"ba0f2faa0d2ac702a88587e696233e85";

// The token is for user coabo (named so for legacy reasons)
NSString *accessToken = @"886be3b1a4bf07b1b3b2e3e25e5dfd07";
NSString *accessSecret = @"2d1a92bd4913a2e58e5b61a07032d9d1";

long testUserId = 2051584651;       // coabo
long testFolloweeId = 2051754781;   // coabo2


@implementation BBWeiboTest

#pragma mark set up and tear down
- (void)setUp
{
    [super setUp];
    weibo = [[BBWeibo alloc] initWithAppKey:(NSString *) appKey
                                     Secret:(NSString *) secret
                                accessToken:(NSString *) accessToken
                               accessSecret:(NSString *) accessSecret
                                   delegate:self];
    done = NO;
}

- (void)tearDown
{
    [weibo release];
    [super tearDown];
}

#pragma mark - test get public timeline
- (void)testGetPublicTimeline
{
    [weibo getPublicTimeline];
    [self sleepUntilDone];
}

-(void) getPublicTimelineFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;

    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *statuses = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(20 >= [statuses count], @"Expected 20 statues or less");
}

#pragma mark - test get friends timeline
- (void)testGetFriendsTimeline
{
    [weibo getFriendsTimeline];
    [self sleepUntilDone];
}

-(void) getFriendsTimelineFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;

    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *statuses = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(20 >= [statuses count], @"Expected 20 statues or less");
}

#pragma mark - test get user timeline
- (void)testGetMyTimeline
{
    [weibo getMyTimeline];
    [self sleepUntilDone];
}

- (void)getGetUserTimeline
{
    [weibo getTimelineForUser:testFolloweeId];
    [self sleepUntilDone];
}

-(void) getUserTimelineFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
 
    // get the request type (for self or for other user) from the request
    BOOL isForMe = YES;
    for (OARequestParameter *param in [[tickets request] parameters]) {
        if ([[param name] isEqualToString:@"id"] || [[param name] isEqualToString:@"user_id"] || [[param name] isEqualToString:@"screen_name"]) {
            isForMe = NO;
            break;
        }
    }
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *statuses = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(20 >= [statuses count], @"Expected 20 statues or less");
    for (BBStatus *status in statuses) {
        if (isForMe) {
            STAssertTrue(status.user.id == testUserId, @"Invalid user id");
        } else {
            STAssertTrue(status.user.id == testFolloweeId, @"Invalid user id");
        }
    }
}

#pragma mark - test get unread
- (void)testGetUnread
{
    [weibo getUnreadSince:-1];
    [self sleepUntilDone];
}

-(void) getUnreadFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    NSDictionary *json = [[JSONDecoder decoder] objectWithData:data];
    STAssertTrue([json isKindOfClass:[NSDictionary class]], @"Expected a dictionary");

    // the actual values are dynamic, here only keys are verified
    STAssertTrue([[json allKeys] containsObject:@"new_status"], @"Expected new_status");
    STAssertTrue([[json allKeys] containsObject:@"followers"], @"Expected followers");
    STAssertTrue([[json allKeys] containsObject:@"dm"], @"Expected dm");
    STAssertTrue([[json allKeys] containsObject:@"comments"], @"Expected comments");
    STAssertTrue([[json allKeys] containsObject:@"mentions"], @"Expected mentions");
}

#pragma mark - test get mentioned me
-(void) testGetMentionedMe
{
    [weibo getMentionedMe];
    [self sleepUntilDone];
}

-(void) getMentionedMeFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *statuses = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(20 >= [statuses count], @"Expected 20 statues or less");
}

#pragma mark - test get comments (from/to the current user)
-(void) testGetComments
{
    [weibo getComments];
    [self sleepUntilDone];
}

-(void) getCommentsFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *comments = [[BBParser defaultInstance] decode:json as:[BBComment class]];
    // all comments should be for statuses of the current user
    for (BBComment *comment in comments) {
        STAssertTrue(testUserId == comment.status.user.id || testUserId == comment.user.id,
                     @"Expected comments to or from current user.");
    }
}

#pragma mark - test get comments to the current user
-(void) testGetCommentsToMe
{
    [weibo getCommentsToMe];
    [self sleepUntilDone];
}

-(void) getCommentsToMeFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *comments = [[BBParser defaultInstance] decode:json as:[BBComment class]];
    // all comments should be for statuses of the current user
    for (BBComment *comment in comments) {
        if (comment.status) {
            STAssertTrue(testUserId == comment.status.user.id,
                         @"Expected comments to current user.");
        } else if (comment.replyComment) {
            STAssertTrue(testUserId == comment.replyComment.user.id,
                         @"Expected comments to current user.");
        }
    }
}

#pragma mark - test get comments from the current user
-(void) testGetCommentsByMe
{
    [weibo getCommentsByMe];
    [self sleepUntilDone];
}

-(void) getCommentsByMeFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *comments = [[BBParser defaultInstance] decode:json as:[BBComment class]];
    // all comments should be for statuses of the current user
    for (BBComment *comment in comments) {
        STAssertTrue(testUserId == comment.user.id,
                     @"Expected comments from current user.");
    }
}

#pragma mark - failure handler
-(void) failed:(OAServiceTicket *) tickets withError:(NSError *) error
{
    STFail(@"Failed with error : %@ for %@", [error localizedDescription], [[tickets response] URL]);
    done = YES;
}

#pragma mark - tools and misc
-(void) sleepUntilDone
{
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while (!done && [runLoop runMode:NSDefaultRunLoopMode beforeDate:loopUntil]) {
        loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    }
}

@end
