//
//  IMLivesManager.h
//  ImpossibleMaze
//
//  Created by Jon Como on 9/10/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ValuesChanged)(void);

@interface IMLivesManager : NSObject

//Archived properties
@property (nonatomic, strong) NSDate *dateOfNextLife;
@property (nonatomic, assign) NSTimeInterval timeInterval;
@property (nonatomic, assign) int lives;

@property (nonatomic, assign) NSTimeInterval secondsUntilNextLife;

@property (nonatomic, copy) ValuesChanged valuesChanged;

+(IMLivesManager *)sharedManager;

@end