//
//  BBUser.m
//  boboa
//
//  Created by Yanbo Wu on 4/2/11.
//

#import "BBUser.h"

@implementation BBUser

@synthesize name;
@synthesize domain;
@synthesize geoEnabled;
@synthesize followersCount;
@synthesize statusesCount;
@synthesize favouritesCount;
@synthesize city;
@synthesize description;
@synthesize verified;
@synthesize id;
@synthesize gender;
@synthesize friendsCount;
@synthesize screenName;
@synthesize allowAllActMsg;
@synthesize following;
@synthesize url;
@synthesize profileImageUrl;
@synthesize createdAt;
@synthesize province;
@synthesize location;
@synthesize status;
@synthesize remark;

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [remark release];
    [status release];
    [name release];
    [domain release];
    [description release];
    [gender release];
    [screenName release];
    [url release];
    [profileImageUrl release];
    [createdAt release];
    [location release];
    [super dealloc];
}

@end
