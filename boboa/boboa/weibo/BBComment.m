//
//  BBComment.m
//  boboa
//
//  Created by Yanbo Wu on 4/24/11.
//

#import "BBComment.h"


@implementation BBComment

@synthesize createdAt;
@synthesize truncated;
@synthesize id;
@synthesize source;
@synthesize user;
@synthesize text;
@synthesize mid;
@synthesize replyComment;
@synthesize status;
@synthesize favorited;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [createdAt release];
    [source release];
    [user release];
    [text release];
    [replyComment release];
    [status release];
    [super dealloc];
}

@end
