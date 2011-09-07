//
//  BBAuthorizer.h
//  boboa
//

#import "OAToken.h"

#define SINA_KEY                     @"2331956207"
#define SINA_SECRET                  @"ba0f2faa0d2ac702a88587e696233e85"
#define SINA_KEYCHAIN                @"twilight-keychain-sina"

#define QQ_KEY                       @"b89a011815de40c18460f8289540429f"
#define QQ_SECRET                    @"cfcd1a6d841e42192f50499f2ede9fe3"
#define QQ_KEYCHAIN                  @"twilight-keychain-qq"


@protocol BBAuthorizerDelegate <NSObject>
-(void) didGetRequestToken:(OAToken *)token;
-(void) failedGetRequestToken;
-(void) didGetAccessToken:(OAToken *)token;
-(void) failedGetAccessToken;
@end


@interface BBAuthorizer : NSObject {
@private
    OAToken *requestToken;
    id<BBAuthorizerDelegate> delegate;
    NSString *appKey;
    NSString *appSecret;
    NSString *keychainName;
    NSDictionary *oauthURLs;
}

+(BBAuthorizer *) sinaAuthorizer;
+(BBAuthorizer *) qqAuthorizer;

-(id) initWithKey:(NSString *)aKey
           secret:(NSString *)aSecret
         keychain:(NSString *)aKeychain
        oauthURLs:(NSDictionary *)map;

-(void) authorize;
-(BOOL) isAuthorized;
-(void) endSession;

-(OAToken *) accessToken;
-(NSString *) authURL;

@property (retain) id<BBAuthorizerDelegate> delegate;

@end

