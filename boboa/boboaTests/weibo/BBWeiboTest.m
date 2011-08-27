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

// NOTE - In all these tests, I assume the service is always available.
// In real implementation, in the xyzDidFinished delegate methods,
// it is REQUIRED to first check the didSucceed flag of the ticket

// The app key and secret here is for boboa.opensource
NSString *appKey = @"2331956207";
NSString *secret = @"ba0f2faa0d2ac702a88587e696233e85";

// The token is for user coabo (named so for legacy reasons)
NSString *accessToken = @"886be3b1a4bf07b1b3b2e3e25e5dfd07";
NSString *accessSecret = @"2d1a92bd4913a2e58e5b61a07032d9d1";

long testUserId = 2051584651;       // coabo
long testFolloweeId = 2051754781;   // coabo2
long testStatusId = 8230462829l;    // http://weibo.com/2051584651/zF4kGJ8v8r
long testRepostId = 14325129074l;
long testToFollowId = 1715716051l;  // the author

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

#pragma mark - test get comments for a status update
-(void) testGetCommentsToStatus
{
    [weibo getCommentsToStatus:testStatusId page:1];
    [self sleepUntilDone];
}

-(void) getCommentsToStatusFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *comments = [[BBParser defaultInstance] decode:json as:[BBComment class]];
    for (BBComment *comment in comments) {
        STAssertTrue(testStatusId == comment.status.id,
                     @"Expected comments to the given status id.");
    }
}

#pragma mark - test get counts
-(void) testGetCounts
{
    NSArray *ids = [NSArray arrayWithObjects:[NSNumber numberWithLong:testStatusId], nil];
    [weibo getCounts:ids];
    [self sleepUntilDone];
}

-(void) getCountsFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;

    id json = [[JSONDecoder decoder] objectWithData:data];
    STAssertTrue([json isKindOfClass:[NSArray class]], @"Expected an arrary.");
    STAssertTrue(1 == [json count], @"Expected an arrary of size 1.");
    NSDictionary *counts = [json objectAtIndex:0];
    STAssertTrue(testStatusId == [[counts objectForKey:@"id"] longValue], @"Expected the given status id");
    STAssertTrue(1 == [[counts objectForKey:@"comments"] longValue], @"Expected one comment");
    STAssertTrue(1 == [[counts objectForKey:@"rt"] longValue], @"Expected no rt");  // This is why weibo is copying twitter
}

#pragma mark - test get repost timeline by user
-(void) testGetRepostTimelineByUser
{
    [weibo getRepostTimelineByUser:testUserId];
    [self sleepUntilDone];
}

-(void) getRepostTimelineByUserFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *statuses = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    for (BBComment *status in statuses) {
        STAssertTrue(testUserId == status.user.id,
                     @"Expected reposts by the given user id.");
    }
}

#pragma mark - test get repost timeline for status
-(void) testGetRepostTimelineForStatus
{
    [weibo getRepostTimelineForStatus:testRepostId];
    [self sleepUntilDone];
}

-(void) getRepostTimelineForStatusFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *statuses = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    for (BBStatus *status in statuses) {
        STAssertTrue(testRepostId == status.retweetedStatus.id,
                     @"Expected reposts by the given user id.");
    }
}

#pragma mark - test post and delete a status
-(void) testPostAndDelete
{
    lastRand = arc4random();
    [weibo post:[NSString stringWithFormat:@"%lu", lastRand]];
    [self sleepUntilDone];
}

-(void) postFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBStatus *status = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(lastRand == [status.text longLongValue], @"Expected the text with last arc4random number");

    // now delete it
    [weibo destroy:status.id];
    done = NO;
    [self sleepUntilDone];
}

-(void) destroyFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBStatus *status = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(lastRand == [status.text longLongValue], @"Expected the text with last arc4random number");
}

#pragma mark - test post and delete a status with an image
-(void) testPostAndDeleteWithImage
{
    lastRand = arc4random();
    [weibo post:[NSString stringWithFormat:@"%lu", lastRand] withImage:[[NSBundle mainBundle] pathForResource:@"logo" ofType:@"png"]];
    [self sleepUntilDone];
}

-(void) uploadFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBStatus *status = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(lastRand == [status.text longLongValue], @"Expected the text with last arc4random number");
    STAssertNotNil(status.thumbnailPic, @"Expected image.");
    
    // now delete it
    [weibo destroy:status.id];
    done = NO;
    [self sleepUntilDone];
}

#pragma mark - test repost and delete
-(void) testRepostAndDelete
{
    lastRand = arc4random();
    [weibo repost:[NSString stringWithFormat:@"%lu", lastRand] toPost:testRepostId];
    [self sleepUntilDone];
}

-(void) repostFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBStatus *status = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(lastRand == [status.text longLongValue], @"Expected the text with last arc4random number");
    
    // now delete it
    [weibo destroy:status.id];
    done = NO;
    [self sleepUntilDone];
}

#pragma mark - test comment and delete
-(void) testCommentAndDelete
{
    lastRand = arc4random();
    [weibo comment:[NSString stringWithFormat:@"%lu", lastRand] toPost:testRepostId];
    [self sleepUntilDone];
}

-(void) commentFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;

    id json = [[JSONDecoder decoder] objectWithData:data];
    BBComment *comment = [[BBParser defaultInstance] decode:json as:[BBComment class]];
    STAssertTrue(lastRand == [comment.text longLongValue], @"Expected the text with last arc4random number");
    
    // now delete it
    [weibo destroyComment:comment.id];
    done = NO;
    [self sleepUntilDone];
}

-(void) destroyCommentFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBComment *comment = [[BBParser defaultInstance] decode:json as:[BBComment class]];
    STAssertTrue(lastRand == [comment.text longLongValue], @"Expected the text with last arc4random number");
}

#pragma mark - test show user followers
-(void) testGetFollowers
{
    [weibo getFollowers:testUserId withCursor:-1];
    [self sleepUntilDone];
}

-(void) getFollowersFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *users = [[BBParser defaultInstance] decode:[json objectForKey:@"users"] as:[BBUser class]];
    for (id user in users) {
        STAssertTrue([user isMemberOfClass:[BBUser class]], @"Expected users.");
    }
}

#pragma mark - test show user followees
-(void) testGetFollowees
{
    [weibo getFollowers:testUserId withCursor:-1];
    [self sleepUntilDone];
}

-(void) getFolloweesFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *users = [[BBParser defaultInstance] decode:[json objectForKey:@"users"] as:[BBUser class]];
    for (id user in users) {
        STAssertTrue([user isMemberOfClass:[BBUser class]], @"Expected users.");
    }
}

#pragma mark - test follow and unfollow
-(void) testFollowAndUnfollow
{
    [weibo follow:testToFollowId];
    [self sleepUntilDone];
}

-(void) followFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBUser *user = [[BBParser defaultInstance] decode:json as:[BBUser class]];
    STAssertTrue(testToFollowId == user.id, @"Expected the given user");

    [weibo unfollow:testToFollowId];
    done = NO;
    [self sleepUntilDone];
}

-(void) unfollowFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBUser *user = [[BBParser defaultInstance] decode:json as:[BBUser class]];
    STAssertTrue(testToFollowId == user.id, @"Expected the given user");
}

#pragma mark - test block and unblock
-(void) testBlockAndUnblock
{
    [weibo block:testToFollowId];
    [self sleepUntilDone];
}

-(void) blockFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    STAssertTrue(testToFollowId == [[json objectForKey:@"id"] longLongValue], @"Expected the given user");
    
    [weibo unblock:testToFollowId];
    done = NO;
    [self sleepUntilDone];
}

-(void) unblockFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    STAssertTrue(testToFollowId == [[json objectForKey:@"id"] longLongValue], @"Expected the given user");
}

#pragma mark - test favor and unfavor
-(void) testFavorAndUnfavor
{
    [weibo addToFavorite:testStatusId];
    [self sleepUntilDone];
}

-(void) createFavoriteFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBStatus *status = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(testStatusId == status.id, @"Expected the given status id");
    
    // now delete it
    [weibo removeFromFavorite:status.id];
    done = NO;
    [self sleepUntilDone];
}

-(void) removeFavoriteFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    BBStatus *status = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(testStatusId == status.id, @"Expected the given status id");
}

#pragma mark - test get topic
-(void) testGetTopic
{
    [weibo getTopic:BB_TOPIC_TIME_FRAME_DAILY];
    [self sleepUntilDone];
}

-(void) getTopicsFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    
    id json = [[JSONDecoder decoder] objectWithData:data];
    STAssertTrue([json isKindOfClass:[NSDictionary class]], @"Expected an NSDictionary.");
    STAssertTrue([[json objectForKey:@"trends"] isKindOfClass:[NSDictionary class]], @"Expected an NSDictionary.");
}

#pragma mark - test get status for topic
-(void) testGetStatusesForTopic
{
    [weibo getStatusesForTopic:@"sina"];
}

-(void) getStatusesForTopicFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;
    id json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *statuses = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue([json isKindOfClass:[NSArray class]], @"Expected an array.");
    for (BBStatus *status in statuses) {
        STAssertTrue([status isMemberOfClass:[BBStatus class]], @"Expected status");
    }
}


#pragma mark - failure handler
-(void) failed:(OAServiceTicket *) tickets withError:(NSError *) error
{
    done = YES;
    STFail(@"Failed with error : %@ for %@", [error localizedDescription], [[tickets response] URL]);
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
