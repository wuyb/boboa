//
//  BBWeiboTests.h
//  BBWeiboTests
//
//  Created by Yanbo Wu on 3/27/11.
//

#import <SenTestingKit/SenTestingKit.h>

#import "BBWeibo.h"

@interface BBWeiboTest : SenTestCase <BBWeiboDelegate> {
@private
    BBWeibo *weibo;
    bool done;
}

-(void)sleepUntilDone;

@end
