//
//  IMLivesManager.h
//  ImpossibleMaze
//
//  Created by Jon Como on 9/10/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ValueChanged)(int);


@interface IMLivesManager : NSObject

@property (nonatomic, assign) int lives;

@property (nonatomic, copy) ValueChanged livesChangedHandler;
@property (nonatomic, copy) ValueChanged secondsChangedHandler;

@property (nonatomic, assign) int interval;
@property (nonatomic, assign) int secondsUntilNextLife;

+(IMLivesManager *)sharedManager;

@end