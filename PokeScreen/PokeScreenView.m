//
//  PokeScreenView.m
//  PokeScreen
//
//  Created by Joss Manger on 3/19/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#import "PokeScreenView.h"
#import "PokeScreen-Swift.h"
#import <os/log.h>

@implementation PokeScreenView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
      self.loader = [[PokemonLoader alloc] init];
      self.singleview = [[NSImageView alloc] initWithFrame:CGRectZero];
      [self.singleview setTranslatesAutoresizingMaskIntoConstraints:FALSE];
      [self.loader loadAllWithCallback:^(NSArray<NSImage *> *arr) {
        os_log_info(OS_LOG_DEFAULT, "%@", arr);
        [self.singleview setImage:(NSImage *)[arr firstObject]];
        [self addSubview:self.singleview];
        [[[self.singleview centerYAnchor] constraintEqualToAnchor:self.centerYAnchor] setActive:YES];
        [[[self.singleview centerXAnchor] constraintEqualToAnchor:self.centerXAnchor] setActive:YES];
        
        
        os_log_info(OS_LOG_DEFAULT, "done");
      }];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
