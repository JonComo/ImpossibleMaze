//
//  IMMenuItem.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/11/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMMenuItem.h"

@implementation IMMenuItem

+(IMMenuItem *)menuItemTitle:(NSString *)title action:(Action)action
{
    IMMenuItem *item = [IMMenuItem new];
    
    item.action = action;
    item.title = title;
    
    return item;
}

@end
