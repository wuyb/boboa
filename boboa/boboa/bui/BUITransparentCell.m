//
//  BUIPushOnOffButtonCell.m
//  boboa
//
//  Created by Yanbo Wu on 9/9/11.
//  Copyright 2011 wuyb.com. All rights reserved.
//

#import "BUITransparentCell.h"

@implementation BUITransparentCell

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (NSColor *)backgroundColor
{
    return [NSColor clearColor];
}

@end
