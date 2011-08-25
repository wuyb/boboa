//
//  BBStatus.m
//  boboa
//
//  Created by Yanbo Wu on 4/2/11.
//

#import "BBStatus.h"


@implementation BBStatus

@synthesize createdAt;
@synthesize truncated;
@synthesize inReplyToStatusId;
@synthesize inReplyToScreenName;
@synthesize favorited;
@synthesize inReplyToUserId;
@synthesize id;
@synthesize source;
@synthesize user;
@synthesize text;
@synthesize mid;
@synthesize geo;
@synthesize annotations;
@synthesize bmiddlePic;
@synthesize originalPic;
@synthesize thumbnailPic;
@synthesize retweetedStatus;
@synthesize numberOfComments;
@synthesize comments;
@synthesize deleted;

- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [retweetedStatus release];
    [bmiddlePic release];
    [originalPic release];
    [thumbnailPic release];
    [annotations release];
    [geo release];
    [createdAt release];
    [text release];
    [inReplyToScreenName release];
    [source release];
    [user release];
    [super dealloc];
}

@end
