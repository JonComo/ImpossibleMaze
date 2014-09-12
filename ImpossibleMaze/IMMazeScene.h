//
//  IMMazeScene.h
//  ImpossibleMaze
//
//  Created by Jon Como on 9/4/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define HIGHSCORE @"highscore"

@class IMMenuViewController;

typedef void (^MazeGenerated)(void);

@interface IMMazeScene : SKScene

@property (nonatomic, weak) IMMenuViewController *presentingViewController;

@property CGSize mazeSize;
@property (nonatomic, strong) UIColor *mazeColor;

@property (nonatomic, copy) MazeGenerated mazeGeneratedHandler;

@property (nonatomic, strong) SKNode *world;

-(id)initWithSize:(CGSize)size mazeColor:(UIColor *)mazeColor;

@end
