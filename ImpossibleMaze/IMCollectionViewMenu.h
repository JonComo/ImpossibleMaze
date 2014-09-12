//
//  IMCollectionViewMenu.h
//  ImpossibleMaze
//
//  Created by Jon Como on 9/11/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IMMenuItem.h"

@interface IMCollectionViewMenu : UIView

@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSArray *colors;

-(void)refresh;

-(UIColor *)randomColor;

@end
