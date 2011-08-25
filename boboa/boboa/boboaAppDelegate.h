//
//  boboaAppDelegate.h
//  boboa
//
//  Created by Yanbo Wu on 3/27/11.
//  Copyright 2011 wuyb.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface boboaAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
