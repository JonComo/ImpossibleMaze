//
//  MZRoom.h
//  Maze
//
//  Created by Jon Como on 6/15/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MZRoom : NSObject

@property BOOL N,S,E,W,hasBeenVisited;
@property int x,y;

@end