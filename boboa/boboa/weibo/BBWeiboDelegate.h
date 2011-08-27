//
//  BBWeiboDelegate.h
//  boboa
//
//  Created by Yanbo Wu on 3/27/11.
//

#import <Foundation/Foundation.h>

// This is the delegate used by the BBWeibo class.
// These methods will be called after the async calls to the service endpoints complete or fail.
// All of them are optional, except the failed:withError: method, thus they can be conformed separately by different classes.
@protocol BBWeiboDelegate <NSObject>

@optional
-(void) getPublicTimelineFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getFriendsTimelineFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getUserTimelineFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getUnreadFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getMentionedMeFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getCommentsFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getCommentsByMeFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getCommentsToMeFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getCommentsToStatusFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getCountsFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getRepostTimelineForStatusFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getRepostTimelineByUserFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) resetCountFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getEmotionsFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) postFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) uploadFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) repostFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) destroyFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) createFavoriteFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) removeFavoriteFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) commentFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) destroyCommentFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) destroyCommentsFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) replyFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) showUserFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getFolloweesFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getFollowersFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getDirectMessageFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getSentDirectMessageFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) sendDirectMessageFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) destroyDirectMessageFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) destroyDirectMessagesFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) followFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) unfollowFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) showRelationshipFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) blockFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) unblockFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) checkBlockFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getBlockListFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) verifyFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getRateLimitStatusFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getFavoritesFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getTopicsFinished: (OAServiceTicket *) tickets withData: (id) data;
-(void) getStatusesForTopicFinished: (OAServiceTicket *) tickets withData: (id) data;

@required
-(void) failed:(OAServiceTicket *) tickets withError:(NSError *) error;

@end
