//
//  IMCellPlain.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/11/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMCellPlain.h"

#import "IMMenuItem.h"

@implementation IMCellPlain
{
    __weak IBOutlet UILabel *label;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setItem:(IMMenuItem *)item
{
    _item = item;
    
    label.text = item.title;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
