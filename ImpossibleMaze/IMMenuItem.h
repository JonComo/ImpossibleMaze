//
//  IMMenuItem.h
//  ImpossibleMaze
//
//  Created by Jon Como on 9/11/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMMenuItem;

typedef void (^Action)(IMMenuItem *item);

@interface IMMenuItem : NSObject

@property (nonatomic, copy) Action action;
@property (nonatomic, copy) NSString *title;

+(IMMenuItem *)menuItemTitle:(NSString *)title action:(Action)action;

@end