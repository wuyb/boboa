//
//  BBUser.h
//  boboa
//
//  Created by Yanbo Wu on 4/2/11.
//  Copyright 2011 wuyb.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBStatus;

// The model class for a user at Sina Weibo.
@interface BBUser : NSObject {
@private
    NSString *name;
    NSString *domain;
    bool geoEnabled;
    int followersCount;
    int statusesCount;
    int favouritesCount;
    int city;
    NSString *description;
    bool verified;
    long long id;
    NSString *gender;
    int friendsCount;
    NSString *screenName;
    bool allowAllActMsg;
    bool following;
    NSString *url;
    NSString *profileImageUrl;
    NSDate *createdAt;
    int province;
    NSString *location;
    BBStatus *status;
    NSString *remark;
}

@property (copy) NSString *remark;
@property (copy) NSString *name;
@property (copy) NSString *domain;
@property bool geoEnabled;
@property int followersCount;
@property int statusesCount;
@property int favouritesCount;
@property int city;
@property (copy) NSString *description;
@property bool verified;
@property long long id;
@property (copy) NSString *gender;
@property int friendsCount;
@property (copy) NSString *screenName;
@property bool allowAllActMsg;
@property bool following;
@property (copy) NSString *url;
@property (copy) NSString *profileImageUrl;
@property (retain) NSDate *createdAt;
@property int province;
@property (copy) NSString *location;
@property (retain) BBStatus *status;

@end