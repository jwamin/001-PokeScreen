//
//  PokeScreenView.h
//  PokeScreen
//
//  Created by Joss Manger on 3/19/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <SceneKit/SceneKit.h>
#import "PokeScreen-Swift.h"

@interface PokeScreenView : ScreenSaverView

@property (strong) PokemonLoader *loader;

@property (strong) PokemonScene *pokemonScene;

@property (strong) SCNView *sceneView;

@end
