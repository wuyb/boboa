//
//  BBStatus.h
//  boboa
//
//  Created by Yanbo Wu on 4/2/11.
//

#import <Foundation/Foundation.h>

#import "BBUser.h"

// TODO annotation is not supported
@interface BBStatus : NSObject {
@private
    long long id;
    long long mid;
    long long inReplyToStatusId;
    long long inReplyToUserId;
    long long numberOfComments;
    bool favorited;
    bool truncated;
    NSString *source;
    NSString *text;
    NSString *inReplyToScreenName;
    NSString *geo;
    NSString *bmiddlePic;
    NSString *originalPic;
    NSString *thumbnailPic;
    NSArray *annotations;
    NSArray *comments;
    NSDate *createdAt;
    BBUser *user;
    BBStatus *retweetedStatus;
}

@property (retain) BBStatus *retweetedStatus;
@property (copy) NSString *bmiddlePic;
@property (copy) NSString *originalPic;
@property (copy) NSString *thumbnailPic;
@property (retain) NSDate *createdAt;
@property (retain) NSString *text;
@property bool truncated;
@property long long inReplyToStatusId;
@property (copy) NSString *inReplyToScreenName;
@property bool favorited;
@property long long inReplyToUserId;
@property long long id;
@property (copy) NSString *source;
@property (retain) BBUser *user;
@property long long mid;
@property (copy) NSString *geo;
@property (retain) NSArray *annotations;
@property long long numberOfComments;
@property (retain) NSArray *comments;

@end
