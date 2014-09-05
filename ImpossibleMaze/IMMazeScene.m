//
//  IMMazeScene.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/4/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMMazeScene.h"

#import "MZMaze.h"

static const uint32_t playerCategory    =  0x1 << 0;
static const uint32_t wallCategory      =  0x1 << 1;

@interface IMMazeScene () <SKPhysicsContactDelegate>

@end

@implementation IMMazeScene
{
    SKSpriteNode *player;
    
    SKLabelNode *highScoreLabel;
    SKSpriteNode *highScoreMarker;
    
    NSMutableArray *walls;
    
    CGPoint currentTouch;
    CGPoint lastTouch;
    
    float lastMazeY;
    
    BOOL createdBottom;
    int top, bottom;
    
    __block BOOL canMoveWalls;
    
    BOOL isGameOver;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [UIColor whiteColor];
        
        NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        _world = [[SKNode alloc] init];
        [self addChild:_world];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, size.width, size.height)];
        
        walls = [NSMutableArray array];
        
        player = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(8, 8)];
        player.position = CGPointMake(size.width/2, size.height/2);
        [self.world addChild:player];
        
        player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:player.size.width/2];
        player.physicsBody.categoryBitMask = playerCategory;
        player.physicsBody.contactTestBitMask = wallCategory;
        player.physicsBody.allowsRotation = NO;
        player.zPosition = 10;
        
        highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
        highScoreLabel.fontSize = 18;
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        highScoreLabel.fontColor = [UIColor redColor];
        highScoreLabel.position = CGPointMake(4, size.height/2);
        highScoreLabel.zPosition = 20;
        [self.world addChild:highScoreLabel];
        
        highScoreMarker = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(40, 4)];
        highScoreMarker.position = CGPointMake(highScoreMarker.size.width/2, player.position.y);
        NSNumber *previousHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:HIGHSCORE];
        if (previousHighScore){
            highScoreMarker.position = CGPointMake(highScoreMarker.position.x, [previousHighScore floatValue]);
        }
        [self.world addChild:highScoreMarker];
        highScoreMarker.zPosition = 10;
        
        lastMazeY = 0;
    }
    return self;
}

-(void)addMazeOfSize:(CGSize)size yPosition:(float)yPosition openTop:(int)openTop openBottom:(int)openBottom
{
    float roomSize = self.size.width/size.width;
    float height = size.height * roomSize;
    
    lastMazeY = yPosition + height;
    yPosition += height;
    
    __weak IMMazeScene *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        MZMaze *maze = [[MZMaze alloc] initWithSize:size];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [maze iterateRooms:^(MZRoom *room) {
                
                CGPoint spawn = CGPointMake(room.x * roomSize + roomSize/2, room.y * roomSize + roomSize/2);
                
                if (!room.S && !(room.x == openTop && room.y == 0)){
                    [weakSelf addWallToPoint:CGPointMake(spawn.x, spawn.y - roomSize/2 + yPosition) size:CGSizeMake(roomSize, roomSize/6)];
                }
                
                if (!room.W && !(room.x == 0)){
                    [weakSelf addWallToPoint:CGPointMake(spawn.x - roomSize/2, spawn.y + yPosition) size:CGSizeMake(roomSize/6, roomSize)];
                }
                
            }];
            
        });
    });
}

-(SKSpriteNode *)addWallToPoint:(CGPoint)point size:(CGSize)size
{
    SKSpriteNode *wall = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:size];
    wall.position = point;
    wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wall.size];
    wall.physicsBody.dynamic = NO;
    
    wall.physicsBody.categoryBitMask = wallCategory;
    wall.physicsBody.contactTestBitMask = playerCategory;
    
    wall.zPosition = 0;
    
    wall.alpha = 1;
    [self.world addChild:wall];
    
    [walls addObject:wall];
    
    return wall;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isGameOver){
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    currentTouch = [[touches anyObject] locationInNode:self];
    lastTouch = currentTouch;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentTouch = [[touches anyObject] locationInNode:self];
    
    self.physicsWorld.gravity = CGVectorMake(currentTouch.x - lastTouch.x, currentTouch.y - lastTouch.y);
    
    lastTouch = currentTouch;
}

-(void)didSimulatePhysics
{
    if (player.position.y < self.size.height/2) player.position = CGPointMake(player.position.x, self.size.height/2);
    
    self.world.position = CGPointMake(self.world.position.x, -player.position.y + self.size.height/2);
}

-(void)update:(CFTimeInterval)currentTime
{
    //highscore
    if (highScoreMarker.position.y < player.position.y){
        highScoreMarker.position = CGPointMake(highScoreMarker.position.x, player.position.y);
        
        highScoreLabel.position = CGPointMake(highScoreLabel.position.x, highScoreMarker.position.y + 4);
        highScoreLabel.text = [NSString stringWithFormat:@"%.0f", highScoreMarker.position.y];
    }
    
    if (player.position.y + self.size.height > lastMazeY){
        if (!createdBottom){
            createdBottom = YES;
            top = arc4random()%(int)self.mazeSize.width;
            bottom = arc4random()%(int)self.mazeSize.width;
        }else{
            bottom = top;
            top = arc4random()%(int)self.mazeSize.width;
        }
        
        [self addMazeOfSize:self.mazeSize yPosition:lastMazeY openTop:top openBottom:bottom];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    [self gameOver];
}

-(void)gameOver
{
    [[NSUserDefaults standardUserDefaults] setObject:@(highScoreMarker.position.y) forKey:HIGHSCORE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for (SKSpriteNode *node in self.world.children){
        node.physicsBody = nil;
    }
    
    player.color = [UIColor redColor];
    [highScoreMarker runAction:[SKAction scaleXTo:100 duration:0.5]];
    
    isGameOver = YES;
}

@end
