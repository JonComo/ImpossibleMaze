//
//  IMCollectionViewMenu.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/11/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMCollectionViewMenu.h"

#import "IMCellPlain.h"

@interface IMCollectionViewMenu () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@end

@implementation IMCollectionViewMenu
{
    UICollectionViewFlowLayout *layout;
    UICollectionView *collectionViewOptions;
    
    float statusBarHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _items = [NSMutableArray array];
        
        layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.itemSize = CGSizeMake(320, 80);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        
        statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        
        collectionViewOptions = [[UICollectionView alloc] initWithFrame:CGRectMake(0, statusBarHeight, frame.size.width, frame.size.height - statusBarHeight) collectionViewLayout:layout];
        [self addSubview:collectionViewOptions];
        
        collectionViewOptions.dataSource = self;
        collectionViewOptions.delegate = self;
        
        collectionViewOptions.alwaysBounceVertical = YES;
        
        [collectionViewOptions registerNib:[UINib nibWithNibName:@"cellPlain" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"cellPlain"];
        
    }
    return self;
}

-(void)setColors:(NSArray *)colors
{
    _colors = colors;
    
    if (colors.count) {
        self.backgroundColor = colors[0];
        collectionViewOptions.backgroundColor = self.backgroundColor;
    }
}

-(void)refresh
{
    layout.itemSize = CGSizeMake(320, (self.frame.size.height - statusBarHeight)/self.items.count);
    [collectionViewOptions reloadData];
}

#pragma mark UICollectionView dataSource/delegate

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    IMCellPlain *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellPlain" forIndexPath:indexPath];
    
    IMMenuItem *item = self.items[indexPath.row];
    cell.item = item;
    
    if (self.colors.count)
        cell.backgroundColor = self.colors[indexPath.row % self.colors.count];
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    IMMenuItem *item = self.items[indexPath.row];
    if (item.action){
        item.action(item);
    }
}

-(UIColor *)randomColor
{
    return self.colors[arc4random()%self.colors.count];
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
