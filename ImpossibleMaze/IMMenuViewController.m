//
//  IMMenuViewController.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/7/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMMenuViewController.h"

#import "RRAudioEngine.h"
#import "IMLivesManager.h"

#import "IMCollectionViewMenu.h"

@import SpriteKit;
#import "IMMazeScene.h"

#define COLOR1 [UIColor colorWithRed:0.698 green:0.000 blue:0.133 alpha:1.000]
#define COLOR2 [UIColor colorWithRed:1.000 green:0.953 blue:0.098 alpha:1.000]
#define COLOR3 [UIColor colorWithRed:1.000 green:0.000 blue:0.188 alpha:1.000]
#define COLOR4 [UIColor colorWithRed:0.078 green:0.592 blue:0.800 alpha:1.000]
#define COLOR5 [UIColor colorWithRed:0.035 green:0.510 blue:0.698 alpha:1.000]


@interface IMMenuViewController ()

@end

@implementation IMMenuViewController
{
    IMCollectionViewMenu *collectionMenu;
    IMMenuItem *nextLife;
    IMMenuItem *lives;
    
    SKView *skView;
    IMMazeScene *scene;
    
    BOOL statusBarHidden;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    collectionMenu = [[IMCollectionViewMenu alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    collectionMenu.colors = @[COLOR1, COLOR2, COLOR3, COLOR4, COLOR5];
    [self.view addSubview:collectionMenu];
    
    [collectionMenu.items addObject:[IMMenuItem menuItemTitle:@"IMPOSSIBLE" action:nil]];
    [collectionMenu.items addObject:[IMMenuItem menuItemTitle:@"INFINITE" action:nil]];
    [collectionMenu.items addObject:[IMMenuItem menuItemTitle:@"MAZE" action:nil]];
    
    lives = [IMMenuItem menuItemTitle:@"LIVES" action:nil];
    [collectionMenu.items addObject:lives];
    
    nextLife = [IMMenuItem menuItemTitle:@"NEXT LIFE: " action:nil];
    [collectionMenu.items addObject:nextLife];
    
    IMMenuViewController *weakSelf = self;
    [collectionMenu.items addObject:[IMMenuItem menuItemTitle:@"PLAY" action:^(IMMenuItem *item) {
        [weakSelf play];
    }]];
    
    //[[RRAudioEngine sharedEngine] playSoundNamed:@"soundtrack" extension:@"wav" loop:YES];
    
    [IMLivesManager sharedManager].valuesChanged = ^(void){
        lives.title = [NSString stringWithFormat:@"LIVES: %i", [IMLivesManager sharedManager].lives];
        nextLife.title = [NSString stringWithFormat:@"NEXT: %.0fs", [IMLivesManager sharedManager].secondsUntilNextLife];
        [collectionMenu refresh];
    };
    
    [collectionMenu refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(BOOL)prefersStatusBarHidden
{
    return statusBarHidden;
}

-(void)play
{
    if ([IMLivesManager sharedManager].lives <= 0) return;
    
    __weak IMMenuViewController *weakSelf = self;
    
    skView = [[SKView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    [skView setMultipleTouchEnabled:NO];
    
    [self.view addSubview:skView];
    
    // Create and configure the scene.
    int colorIndex = arc4random()%collectionMenu.colors.count;
    
    scene = [[IMMazeScene alloc] initWithSize:skView.bounds.size mazeColor:collectionMenu.colors[colorIndex]];
    
    scene.backgroundColor = collectionMenu.colors[(colorIndex + 2)%collectionMenu.colors.count];
    scene.mazeSize = CGSizeMake(12, 12);
    
    scene.presentingViewController = self;
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    [skView presentScene:scene];
    
    skView.layer.transform = CATransform3DMakeScale(0, 0, 0);
    
    __weak SKView *weakSKView = skView;
    scene.mazeGeneratedHandler = ^{
        [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:14 options:0 animations:^{
            weakSKView.layer.transform = CATransform3DIdentity;
        } completion:nil];
    };
    
    statusBarHidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf setNeedsStatusBarAppearanceUpdate];
    }];
}

-(void)reset
{
    __weak IMMenuViewController *weakSelf = self;
    skView.paused = YES;
    
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        skView.layer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01);
    } completion:^(BOOL finished) {
        [skView removeFromSuperview];
        skView = nil;
        scene = nil;
    }];
    
    statusBarHidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf setNeedsStatusBarAppearanceUpdate];
    }];
}

@end
