//
//  IMMazeScene.h
//  ImpossibleMaze
//
//  Created by Jon Como on 9/4/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define HIGHSCORE @"highscore"

@interface IMMazeScene : SKScene

@property (nonatomic, weak) UIViewController *presentingViewController;

@property CGSize mazeSize;
@property (nonatomic, strong) SKNode *world;

@end
