//
//  BBComment.h
//  boboa
//
//  Created by Yanbo Wu on 4/24/11.
//

#import <Foundation/Foundation.h>

#import "BBUser.h"
#import "BBStatus.h"

@interface BBComment : NSObject {
@private
    long long id;
    long long mid;
    bool favorited;
    bool truncated;
    NSString *source;
    NSString *text;
    NSDate *createdAt;
    BBUser *user;
    BBStatus *status;
    BBComment *replyComment;
}

@property (retain) BBComment *replyComment;
@property (retain) BBStatus *status;
@property (retain) NSDate *createdAt;
@property (copy) NSString *text;
@property bool truncated;
@property bool favorited;
@property long long id;
@property (copy) NSString *source;
@property (retain) BBUser *user;
@property long long mid;

@end
