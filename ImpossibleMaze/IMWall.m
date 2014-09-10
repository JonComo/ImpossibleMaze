//
//  IMWall.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/7/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMWall.h"

@implementation IMWall
{
    CGPoint initialPosition;
    CGPoint randomPosition;
    float ratio;
}

-(id)initWithColor:(UIColor *)color size:(CGSize)size position:(CGPoint)position
{
    if (self = [super initWithColor:color size:size]) {
        //init
        self.position = position;
        
        ratio = 1;
        
        initialPosition = position;
        randomPosition = CGPointMake(position.x + (float)(arc4random()%40)-40.0, position.y + (float)(arc4random()%20));
    }
    
    return self;
}

-(void)updateWithOffset:(float)offset
{
    /*
    if (ratio <= 0) return;
    
    float tempRatio = (initialPosition.y - (offset + 140))/80.0;
    
    ratio = MIN(tempRatio, ratio);
    ratio = MAX(0, ratio);
    
    self.position = CGPointMake(initialPosition.x + randomPosition.x * ratio, initialPosition.y + randomPosition.y * ratio); */
}

@end