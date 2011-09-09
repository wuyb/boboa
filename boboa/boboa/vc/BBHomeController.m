//
//  BBHomeController.m
//  boboa
//
//  Created by Yanbo Wu on 9/9/11.
//  Copyright 2011 wuyb.com. All rights reserved.
//

#import "BBHomeController.h"

@implementation BBHomeController

@synthesize tabBar;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [tabBar release];
    [super dealloc];
}
@end
