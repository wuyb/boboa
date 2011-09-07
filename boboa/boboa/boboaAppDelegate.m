//
//  boboaAppDelegate.m
//  boboa
//
//  Created by Yanbo Wu on 8/24/11.
//

#import "boboaAppDelegate.h"
#import "BBAuthorizer.h"

@implementation boboaAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    if (![[BBAuthorizer sinaAuthorizer] isAuthorized]) {
        [[NSBundle mainBundle] loadNibFile:@"BBAuth" externalNameTable:nil withZone:nil];
    }
}

@end
