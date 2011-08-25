//
//  BBWeiboTest.m
//  boboa
//
//  Created by Yanbo Wu on 8/24/11.
//

#import "BBWeiboTest.h"
#import "BBParser.h"
#import "BBStatus.h"
#import "JSONKit.h"

NSString *appKey = @"use your own key";
NSString *secret = @"use your own secret";
NSString *accessToken = @"e26a876392a5ed8c5b3875294e91ebb2";
NSString *accessSecret = @"ffbe496231792604030717fcda25a50e";


@implementation BBWeiboTest

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

- (void)testGetPublicTimeline
{
    [weibo getPublicTimeline];
    [self sleepUntilDone];
}

-(void) getPublicTimelineFinished: (OAServiceTicket *) tickets withData: (id) data
{
    done = YES;

    NSString *json = [[JSONDecoder decoder] objectWithData:data];
    NSArray *statuses = [[BBParser defaultInstance] decode:json as:[BBStatus class]];
    STAssertTrue(20 >= [statuses count], @"Expected 20 statues or less");
}

-(void) failed:(OAServiceTicket *) tickets withError:(NSError *) error
{
    STFail(@"Failed with error : %@ for %@", [error localizedDescription], [[tickets response] URL]);
    done = YES;
}

-(void) sleepUntilDone
{
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    while (!done && [runLoop runMode:NSDefaultRunLoopMode beforeDate:loopUntil]) {
        loopUntil = [NSDate dateWithTimeIntervalSinceNow:1];
    }
}

@end
