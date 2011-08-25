//
//  BBWeibo.h
//  boboa
//
//  Created by Yanbo Wu on 3/27/11.
//

#import <Foundation/Foundation.h>

#import "OAuthConsumer.h"
#import "BBWeiboDelegate.h"

typedef enum {
    BB_STATUS_TYEP_COMMENT = 1,
    BB_STATUS_TYPE_MENTION = 2,
    BB_STATUS_TYPE_DM = 3,
    BB_STATUS_TYPE_FOLLOWER = 4
} STATUS_TYPE;

typedef enum {
    BB_TOPIC_TIME_FRAME_HOURLY,
    BB_TOPIC_TIME_FRAME_DAILY,
    BB_TOPIC_TIME_FRAME_WEEKLY
} BB_TOPIC_TIME_FRAME;

// This class wraps the operations to get information from Sina Weibo platform.
// Note, all the methods in this class are asynchronous. The delegate in the init method is supposed to handle the results.
// This class is thread safe.
@interface BBWeibo : NSObject {
@private
    // the configurations, including REST endpoints etc. this field is readonly after creation
    NSDictionary *conf;
    // the OAuth consumer, initialized with the key/secret parameters in the 'init' method. this field is readonly after creation
    OAConsumer *consumer;
    // the access toekn, initialized with the token/secret parameters in the 'init' method. this field is readonly after creation
    OAToken *token;
    // the delegate. this field is readonly after creation
    id<BBWeiboDelegate> delegate;
}

@property (retain) id<BBWeiboDelegate> delegate;

// Init with app key/secret, access key/secret.
// These information are provided by user of this class, and none of them can be nil.
// If anything goes wrong, nil is returned. The user of this class is responsible for handling this situation.
-(id) initWithAppKey:(NSString *) appKey
              Secret:(NSString *) secret
         accessToken:(NSString *) accessToken
        accessSecret:(NSString *) accessSecret
            delegate:(id<BBWeiboDelegate>) delegate;

// Gets the public timeline statuses.
// This is rarely used, only exists for testing purpose, and maybe future use.
-(void) getPublicTimeline;

-(void) getPublicTimeline: (NSArray *)params;

// Gets the statuses of user's followees, using server default parameters.
-(void) getFriendsTimeline;

// Gets the (first 'count') statuses of user's followees since the given sinceId.
// If the parameter(s) is -1, it(they) will be ignored.
-(void) getFriendsTimelineSince:(long) sinceId withCount:(int) count;

// Gets the (first 'count') statuses of user's followees bfore the given beforeId.
// If the parameter(s) is -1, it(they) will be ignored.
-(void) getFriendsTimelineBefore:(long) beforeId withCount:(int) count;

// Gets the statuses of user's followees, using the given parameters.
-(void) getFriendsTimeline:(NSArray *)params;

// Gets my statuses, using server default parameters.
-(void) getMyTimeline;

// Gets my timeline since the given sinceId.
-(void) getMyTimelineSince:(long) sinceId withCount:(int) count;

// Gets my timeline, using the given parameters.
-(void) getMyTimeline:(NSArray *)params;

// Gets the timeline for the given user.
-(void) getTimelineForUser:(long)id;

// Gets the timeline for the given user since the given sinceId.
-(void) getTimelineForUser:(long)id since:(long)sinceId withCount:(int)count;

// Gets the timeline for the given user before the given sinceId.
-(void) getTimelineForUser:(long)id before:(long)sinceId withCount:(int)count;

// Gets the timeline for the given user with the parameters.
-(void) getTimelineForUser:(long)id withParameters:(NSArray *)params;

// Gets the unread information (not the statuses themselves) since the given sinceId.
-(void) getUnreadSince:(long)sinceId;

// Gets the statues mentioned me.
-(void) getMentionedMe;

// Gets the statues mentioned me since the given id.
-(void) getMentionedMeSince:(long)sinceId withCount:(int)count;
-(void) getMentionedMeBefore:(long)beforeId withCount:(int)count;

// Gets the statuss mentioned me by parameters.
-(void) getMentionedMe:(NSArray *)parameters;

// Gets all the comments to/by me.
-(void) getComments;

// Gets all the comments to/by me since the given sinceId.
-(void) getCommentsPage:(int)page withCount:(int)count;

// Gets all the comments by the parameters.
-(void) getComments:(NSArray *)parameters;

// Gets comments by me.
-(void) getCommentsByMe;

// Gets comments by me since the given sinceId.
-(void) getCommentsByMeSince:(long)sinceId withCount:(int)count;

// Gets comments by me with the parameters.
-(void) getCommentsByMe:(NSArray *)parameters;

// Gets comments to me.
-(void) getCommentsToMe;

// Gets comments to me since the given sinceId.
-(void) getCommentsToMeSince:(long)sinceId withCount:(int)count;
-(void) getCommentsToMeBefore:(long)sinceId withCount:(int)count;

// Gets comments to me with the parameters.
-(void) getCommentsToMe:(NSArray *)parameters;

// Gets comments to the given status.
-(void) getCommentsToStatus:(long)id page:(int)page;

// Gets comments to the given status with parameters.
-(void) getCommentsToStatus:(long)id withParameters:(NSArray *)parameters;

// Gets the counts (comments/forwards) of the given ids.
-(void) getCounts:(NSArray *) ids;

// Gets repost timeline for the given status.
-(void) getRepostTimelineFor:(long)id;

// Gets repost timeline for the given status since the given sinceId.
-(void) getRepostTimelineFor:(long)id since:(long)sinceId withCount:(int)count;

// Gets repost timeline for the given status with given parameters.
-(void) getRepostTimelineFor:(long)id withParameters:(NSArray *)parameters;

// Gets repost timeline by given user for the given status.
-(void) getRepostTimelineBy:(long)id;

// Gets repost timeline by given user for the given status since the given sinceId.
-(void) getRepostTimelineBy:(long)id since:(long)sinceId withCount:(int)count;

// Gets repost timeline by given user for the given status with given parameters.
-(void) getRepostTimelineBy:(long)id withParameters:(NSArray *)parameters;

// Resets the count of the given type (1-4: comments, mentioned, private message, followees).
-(void) resetCountForType:(int)type;

// Gets all the emotions.
-(void) getEmotionsForType:(NSString *)type;

// Deletes a message.
-(void) destroy:(long)id;

// Posts a message.
-(void) post:(NSString *)text;

// Posts a message with parameters.
-(void) post:(NSString *)text withParameters:(NSArray *)parameters;

// Posts a message with an image.
-(void) post:(NSString *)text withImage:(NSString *)imagePath;

// Reposts a post with given text.
-(void) repost:(NSString *) text toPost:(long)id;

// Reposts a post with given text, and the parameters.
-(void) repost:(NSString *) text toPost:(long)id withParameters:(NSArray *)parameters;

// Makes a comment to the given post.
-(void) comment:(NSString *) text toPost:(long)id;
-(void) comment:(NSString *) text toPost:(long)id repost:(BOOL)repost;

// Makes a comment to the given post's some comment.
-(void) comment:(NSString *) text toPost:(long)id comment:(long)id;

// Makes a comment to the given post with parameters.
-(void) comment:(NSString *) text toPost:(long)id withParameters:(NSArray *)parameters;

// Destroys a given comment.
-(void) destroyComment:(long)id;

// Destroys a given comments.
-(void) destroyComments:(NSArray *)ids;

// Replies to a comment.
-(void) reply:(NSString *) text toPost:(long)id andComment:(long)cid;

// Shows the information of the given user.
-(void) showUser:(long) id;
-(void) showUserByScreenName:(NSString*) screenName;

// Shows the followee list.
-(void) getFollowees:(long) id withCursor:(int)nextCursor;

-(void) getFollowees:(long) id withCursor:(int)nextCursor count:(int)count;

// Shows the followee list with parameters.
-(void) getFollowees:(long) id withParameters:(NSArray *)parameters;

// Shows the follower list.
-(void) getFollowers:(long) id withCursor:(int)nextCursor;

// Shows the follower list with parameters.
-(void) getFollowers:(long) id withParameters:(NSArray *)parameters;

// Gets direct message.
-(void) getDirectMessage;

// Gets direct message.
-(void) getDirectMessageSince:(long)sinceId withCount:(int)count;
-(void) getDirectMessageBefore:(long)beforeId withCount:(int)count;

// Gets direct message.
-(void) getDirectMessageWithParameters:(NSArray *)parameters;

// Gets sent direct message.
-(void) getSentDirectMessage;

// Gets sent direct message.
-(void) getSentDirectMessageSince:(long)sinceId withCount:(int)count;

// Gets sent direct message.
-(void) getSentDirectMessageWithParameters:(NSArray *)parameters;

// Sends a direct message.
-(void) sendDirectMessage:(NSString *) text to:(long)id;

// Destroys a direct message.
-(void) destroyDirectMessage:(long)id;

// Destroys a batch of direct messages.
-(void) destroyDirectMessages:(NSArray *)ids;

// Follows a user.
-(void) follow:(long)id;

// Unfollows a user.
-(void) unfollow:(long)id;

// Shows the relationship between 'me' and the given user.
-(void) showRelationship:(long)id;

// Shows the relationship between user a and user b.
-(void) showRelationshipBetween:(long)aid and:(long)bid;

// Blocks a user.
-(void) block:(long)id;

// Unblocks a user.
-(void) unblock:(long)id;

// Checks whether the user is blocked.
-(void) isBlocked:(long)id;

// Gets the list of users are blocked.
-(void) getBlockList;

// Verifies whether the user has sina weibo account.
-(void) verify;

// Gets the user's rate limit status.
-(void) getRateLimitStatus;

// Adds the given status to favorites.
-(void) addToFavorite:(long)id;
-(void) removeFromFavorite:(long)id;
-(void) getFavoritesForPage:(NSUInteger)pageId;
-(void) getFavoirtesWithParameters:(NSArray*)parameters;

// topics
-(void) getTopic:(BB_TOPIC_TIME_FRAME)ttf;
-(void) getStatusesForTopic:(NSString *)topics;

@end

