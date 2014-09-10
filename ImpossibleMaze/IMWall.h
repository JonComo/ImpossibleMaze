//
//  IMWall.h
//  ImpossibleMaze
//
//  Created by Jon Como on 9/7/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface IMWall : SKSpriteNode

-(id)initWithColor:(UIColor *)color size:(CGSize)size position:(CGPoint)position;
-(void)updateWithOffset:(float)offset;

@end
