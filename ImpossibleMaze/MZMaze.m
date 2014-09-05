//
//  MZMaze.m
//  Maze
//
//  Created by Jon Como on 6/14/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "MZMaze.h"

@implementation MZMaze

-(id)initWithSize:(CGSize)mazeSize
{
    if (self = [super init]) {
        //init
        [self generateMazeOfSize:mazeSize];
    }
    
    return self;
}

-(void)generateMazeOfSize:(CGSize)mazeSize
{
    int x;
    int y;
    
    NSMutableArray *stack;
    
    MZRoom *room;
    
    self.size = mazeSize;
    
    self.maze = [NSMutableArray array];
    
    int width = self.size.width;
    int height = self.size.height;
    
    for (int i = 0; i<width; i++) {
        
        self.maze[i] = [NSMutableArray array];
        
        for (int j = 0; j<height; j++) {
            
            MZRoom *newRoom = [MZRoom new];
            
            newRoom.x = i;
            newRoom.y = j;
            
            self.maze[i][j] = newRoom;
        }
    }
    
    x = 0;
    y = 0;
    
    stack = [NSMutableArray array];
    
    room = self.maze[x][y];
    
    BOOL iterate = YES;
    
    while (iterate) {
        [stack addObject:room];
        room.hasBeenVisited = YES;
        
        x = room.x;
        y = room.y;
        
        NSMutableArray *openRooms = [NSMutableArray array];
        
        MZRoom *n = [self roomAtX:x y:y-1];
        if (n) [openRooms addObject:n];
        
        MZRoom *s = [self roomAtX:x y:y+1];
        if (s) [openRooms addObject:s];
        
        MZRoom *e = [self roomAtX:x+1 y:y];
        if (e) [openRooms addObject:e];
        
        MZRoom *w = [self roomAtX:x-1 y:y];
        if (w) [openRooms addObject:w];
        
        if (openRooms.count > 0)
        {
            MZRoom *randomRoom = [openRooms objectAtIndex:arc4random()%openRooms.count];
            
            if (randomRoom == n){
                n.N = YES;
                room.S = YES;
            }
            
            if (randomRoom == s){
                s.S = YES;
                room.N = YES;
            }
            
            if (randomRoom == e){
                e.W = YES;
                room.E = YES;
            }
            
            if (randomRoom == w){
                w.E = YES;
                room.W = YES;
            }
            
            room = randomRoom;
        }else{
            [stack removeObject:room];
            
            if (stack.count > 0)
            {
                room = [stack lastObject];
            }else{
                iterate = NO;
            }
        }
    }
}

-(void)iterateRooms:(void(^)(MZRoom *room))block
{
    for (int i = 0; i<self.size.width; i++) {
        for (int j = 0; j<self.size.height; j++) {
            if (block) block(self.maze[i][j]);
        }
    }
}

-(MZRoom *)roomAtX:(int)xPos y:(int)yPos
{
    if (xPos < 0)
        return nil;
    if (xPos > self.size.width - 1)
        return nil;
    
    if (yPos < 0)
        return nil;
    if (yPos > self.size.height - 1)
        return nil;
    
    MZRoom *foundRoom = self.maze[xPos][yPos];
    
    if (foundRoom.hasBeenVisited)
        return nil;
    
    return foundRoom;
}

@end
