//
//  AppOverlayerWindow.m
//  homeland2
//
//  Created by dualface on 14-6-8.
//  Copyright (c) 2014年 qeeplay.com. All rights reserved.
//

#import "AppOverlayerWindow.h"

@implementation AppOverlayerWindow

- (id) init
{
    self = [super init];
    if (self)
    {
        [self setStyleMask:NSBorderlessWindowMask];
        [self setAcceptsMouseMovedEvents:YES];
        [self setLevel:NSNormalWindowLevel];
    }
    return self;
}

- (BOOL) canBecomeKeyWindow
{
    return YES;
}

- (BOOL) canBecomeMainWindow
{
    return YES;
}

- (BOOL) acceptsFirstResponder
{
    return YES;
}

- (BOOL) becomeFirstResponder
{
    return YES;
}

- (BOOL) resignFirstResponder
{
    return YES;
}

@end
