//
//  IMMyScene.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/3/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMMyScene.h"

#import "MZMaze.h"

@implementation IMMyScene
{
    SKSpriteNode *player;
    
    NSMutableArray *walls;
    
    CGPoint currentTouch;
    CGPoint lastTouch;
    
    float yProgress;
    float lastMazeY;
    
    BOOL createdTop;
    int top, bottom;
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, size.width, size.height)];
        
        walls = [NSMutableArray array];
        
        player = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(10, 10)];
        player.position = CGPointMake(size.width/2, size.height/2);
        [self addChild:player];
        
        player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:player.size.width/2];
        
        lastMazeY = 0;
        yProgress = 0;
    }
    return self;
}

-(void)addMazeOfSize:(CGSize)size yPosition:(float)yPosition openTop:(int)openTop openBottom:(int)openBottom
{
    MZMaze *maze = [[MZMaze alloc] initWithSize:size];
    
    float roomSize = self.size.width/size.width;
    float height = size.height * roomSize;
    
    lastMazeY = yPosition - height/2;
    
    yPosition -= height;
    
    [maze iterateRooms:^(MZRoom *room) {
        
        CGPoint spawn = CGPointMake(room.x * roomSize + roomSize/2, room.y * roomSize + roomSize/2);
        
        if (!room.N && !(room.x == openTop && room.y == (int)size.height-1)){
            [self addWallToPoint:CGPointMake(spawn.x, spawn.y + roomSize/2 + yPosition) size:CGSizeMake(roomSize, roomSize/6)];
        }
        
        if (!room.W && !(room.x == 0)){
            [self addWallToPoint:CGPointMake(spawn.x - roomSize/2, spawn.y + yPosition) size:CGSizeMake(roomSize/6, roomSize)];
        }
        
        if (!room.S && !(room.x == openBottom && room.y == 0)){
            [self addWallToPoint:CGPointMake(spawn.x, spawn.y - roomSize/2 + yPosition) size:CGSizeMake(roomSize, roomSize/6)];
        }
    }];
}

-(SKSpriteNode *)addWallToPoint:(CGPoint)point size:(CGSize)size
{
    SKSpriteNode *wall = [[SKSpriteNode alloc] initWithColor:[UIColor orangeColor] size:size];
    wall.position = point;
    wall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:wall.size];
    wall.physicsBody.dynamic = NO;
    wall.alpha = 0.2;
    [self addChild:wall];
    
    [walls addObject:wall];
    
    return wall;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
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
    float yOffset = player.position.y - self.size.height/2;
    
    yProgress += yOffset;
    
    player.position = CGPointMake(player.position.x, self.size.height/2);
    
    for (SKSpriteNode *wall in walls){
        wall.position = CGPointMake(wall.position.x, wall.position.y - yOffset);
    }
    
    NSLog(@"Progress: %f", yProgress);
    
    if (yProgress < lastMazeY){
        CGSize size = CGSizeMake(8, 2);
        
        if (!createdTop){
            createdTop = YES;
            top = arc4random()%(int)size.width;
            bottom = arc4random()%(int)size.width;
        }else{
            top = bottom;
            bottom = arc4random()%(int)size.width;
        }
        
        [self addMazeOfSize:size yPosition:lastMazeY openTop:top openBottom:bottom];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
