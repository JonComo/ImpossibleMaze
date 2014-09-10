//
//  IMMazeScene.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/4/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMMazeScene.h"

#import "IMWall.h"
#import "MZMaze.h"

@import AudioToolbox;

static const uint32_t playerCategory    =  0x1 << 0;
static const uint32_t wallCategory      =  0x1 << 1;

static const float highScorePadding = 2.0;
static const float highScoreBackgroundPadding = 4.0;

@interface IMMazeScene () <SKPhysicsContactDelegate>

@end

@implementation IMMazeScene
{
    SKSpriteNode *player;
    
    SKLabelNode *highScoreLabel;
    SKSpriteNode *highScoreLabelBackground;
    SKSpriteNode *highScoreMarker;
    
    NSMutableArray *walls;
    
    CGPoint currentTouch;
    CGPoint lastTouch;
    
    float lastMazeY;
    
    BOOL createdBottom;
    int top, bottom;
    
    __block BOOL canMoveWalls;
    
    BOOL isGameOver;
    
    int slowUpdate;
    
    int shakeAmount;
    SKNode *root;
    
    float score;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size])
    {
        self.backgroundColor = [UIColor whiteColor];
                
        //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
        //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
        
        root = [[SKNode alloc] init];
        [self addChild:root];
        
        _world = [[SKNode alloc] init];
        [root addChild:_world];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, size.width, size.height)];
        
        walls = [NSMutableArray array];
        
        player = [[SKSpriteNode alloc] initWithColor:[UIColor blackColor] size:CGSizeMake(8, 8)];
        player.position = CGPointMake(size.width/2, size.height/2);
        [self.world addChild:player];
        
        player.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:player.size.width * 0.4];
        player.physicsBody.categoryBitMask = playerCategory;
        player.physicsBody.contactTestBitMask = wallCategory;
        player.physicsBody.allowsRotation = NO;
        player.zPosition = 10;
        
        highScoreLabelBackground = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:highScoreLabel.frame.size];
        highScoreLabelBackground.position = highScoreLabel.position;
        highScoreLabelBackground.zPosition = 12;
        [self.world addChild:highScoreLabelBackground];
        
        highScoreMarker = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(400, 2)];
        highScoreMarker.position = CGPointMake(size.width/2, player.position.y + player.size.height/2);
        highScoreMarker.zPosition = 10;
        [self.world addChild:highScoreMarker];
        
        highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
        highScoreLabel.fontSize = 18;
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        highScoreLabel.fontColor = [UIColor whiteColor];
        highScoreLabel.zPosition = 20;
        highScoreLabel.text = @"0";
        [self.world addChild:highScoreLabel];
        
        
        NSNumber *previousHighScore = [[NSUserDefaults standardUserDefaults] objectForKey:HIGHSCORE];
        if (previousHighScore){
            highScoreMarker.position = CGPointMake(highScoreMarker.position.x, [previousHighScore floatValue]);
        }
        
        [self updateHighScoreLabel];
        
        lastMazeY = 0;
        
        slowUpdate = 0;
        shakeAmount = 0;
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
                    [weakSelf addWallToPoint:CGPointMake(spawn.x, spawn.y - roomSize/2 + yPosition) size:CGSizeMake(roomSize + roomSize/6, roomSize/6)];
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
    IMWall *wall = [[IMWall alloc] initWithColor:[UIColor blackColor] size:size position:point];

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
        [self.presentingViewController dismissViewControllerAnimated:NO completion:nil];
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
    
    //highscore
    score = player.position.y + player.size.height/2;
    if (highScoreMarker.position.y < score){
        highScoreMarker.position = CGPointMake(highScoreMarker.position.x, score);
        
        [self updateHighScoreLabel];
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    if (shakeAmount > 0){
        float offsetX = (float)(arc4random()%shakeAmount) - (float)shakeAmount/2;
        float offsetY = (float)(arc4random()%shakeAmount) - (float)shakeAmount/2;
        root.position = CGPointMake(offsetX, offsetY);
        shakeAmount--;
    }else{
        root.position = CGPointZero;
    }
    
    if (isGameOver) return; // ************************************* Game Over *********************************
    
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
    
    for (IMWall *wall in walls){
        [wall updateWithOffset:player.position.y];
    }
    
    slowUpdate ++;
    if (slowUpdate > 80){
        slowUpdate = 0;
        [self updateHighScoreLabel];
    }
}

-(void)updateHighScoreLabel
{
    highScoreLabel.text = [NSString stringWithFormat:@"%.0f", highScoreMarker.position.y];
    highScoreLabel.position = CGPointMake(highScoreLabel.position.x, highScoreMarker.position.y - highScoreLabel.frame.size.height/2);
    
    if (player.position.x < self.size.width/2){
        highScoreLabel.position = CGPointMake(self.size.width - highScorePadding, highScoreLabel.position.y);
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    }else{
        highScoreLabel.position = CGPointMake(highScorePadding, highScoreLabel.position.y);
        highScoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    }
    
    //background view
    if (highScoreLabel.horizontalAlignmentMode == SKLabelHorizontalAlignmentModeLeft){
        highScoreLabelBackground.position = CGPointMake(highScoreLabel.position.x + highScoreLabel.frame.size.width/2, highScoreLabel.position.y + highScoreLabel.frame.size.height/2);
    }else{
        highScoreLabelBackground.position = CGPointMake(highScoreLabel.position.x - highScoreLabel.frame.size.width/2, highScoreLabel.position.y + highScoreLabel.frame.size.height/2);
    }
    
    highScoreLabelBackground.size = CGSizeMake(highScoreLabel.frame.size.width + highScoreBackgroundPadding, highScoreLabel.frame.size.height + highScoreBackgroundPadding);
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    [self runAction:[SKAction playSoundFileNamed:@"Die.wav" waitForCompletion:NO]];
    [self gameOver];
}

-(void)gameOver
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    [[NSUserDefaults standardUserDefaults] setObject:@(highScoreMarker.position.y) forKey:HIGHSCORE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    for (SKSpriteNode *node in self.world.children){
        node.physicsBody = nil;
    }
    
    player.color = [UIColor redColor];
    [highScoreMarker runAction:[SKAction scaleXTo:20 duration:0.5]];
    
    shakeAmount = 12;
    
    isGameOver = YES;
}

@end
