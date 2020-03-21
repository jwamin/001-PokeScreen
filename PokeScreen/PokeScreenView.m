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
      self.sceneView = [[SCNView alloc] initWithFrame:CGRectZero options:nil];
      [self.sceneView setTranslatesAutoresizingMaskIntoConstraints:FALSE];
      [self.sceneView setBackgroundColor:[NSColor grayColor]];
      [self addSubview:self.sceneView];
      NSArray<NSLayoutConstraint*> *constraints = @[
      [[self.sceneView topAnchor] constraintEqualToAnchor:self.topAnchor],
      [[self.sceneView bottomAnchor] constraintEqualToAnchor:self.bottomAnchor],
      [[self.sceneView leadingAnchor] constraintEqualToAnchor:self.leadingAnchor],
      [[self.sceneView trailingAnchor] constraintEqualToAnchor:self.trailingAnchor]
      ];
      [NSLayoutConstraint activateConstraints:constraints];
      
      self.pokemonScene = [[PokemonScene alloc] initWithView:self.sceneView load:true];
      
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
