//
//  IMMazeViewController.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/4/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMMazeViewController.h"

#import "IMMazeScene.h"

@interface IMMazeViewController ()
{
    IMMazeScene *scene;
}

@end

@implementation IMMazeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    [skView setMultipleTouchEnabled:NO];
    
    // Create and configure the scene.
    scene = [IMMazeScene sceneWithSize:skView.bounds.size];
    scene.mazeSize = CGSizeMake(16, 16);
    
    scene.presentingViewController = self;
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    [skView presentScene:scene];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
