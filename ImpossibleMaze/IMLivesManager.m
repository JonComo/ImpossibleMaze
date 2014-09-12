//
//  IMLivesManager.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/10/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMLivesManager.h"

static NSString *IMDateOfNextLifeKey = @"dateOfNextLife";
static NSString *IMTimeIntervalKey = @"timeInterval";
static NSString *IMLivesKey = @"lives";

static int IMDefaultLives = 10;
static int IMDefaultInterval = 30;
static int IMLivesMax = 20;

@implementation IMLivesManager
{
    NSTimer *timerUpdate;
}

+(IMLivesManager *)sharedManager
{
    static IMLivesManager *sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [IMLivesManager new];
    });
    
    return sharedManager;
}

-(id)init
{
    if (self = [super init]) {
        //init
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationBecameActive) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationBecameInactive) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleApplicationBecameInactive) name:UIApplicationWillTerminateNotification object:nil];
        
        [self unarchiveProperties];
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setValuesChanged:(ValuesChanged)valuesChanged
{
    _valuesChanged = valuesChanged;
    
    valuesChanged();
}

-(void)handleApplicationBecameActive
{
    timerUpdate = [NSTimer scheduledTimerWithTimeInterval:.2 target:self selector:@selector(updateSeondsUntilNextDate) userInfo:nil repeats:YES];
}

-(void)handleApplicationBecameInactive
{
    [timerUpdate invalidate];
    timerUpdate = nil;
    
    [self archiveProperties];
}

-(void)updateSeondsUntilNextDate
{
    self.secondsUntilNextLife = [self.dateOfNextLife timeIntervalSinceNow];
    
    //NSLog(@"Seconds until next: %f", self.secondsUntilNextLife);
    
    while (self.secondsUntilNextLife < 0){
        self.dateOfNextLife = [self.dateOfNextLife dateByAddingTimeInterval:self.timeInterval];
        self.lives ++;
        self.lives = MIN(self.lives, IMLivesMax);
        
        self.secondsUntilNextLife = [self.dateOfNextLife timeIntervalSinceNow];
    }
    
    if (self.valuesChanged) self.valuesChanged();
}

-(void)unarchiveProperties
{
    NSNumber *interval = [[NSUserDefaults standardUserDefaults] objectForKey:IMTimeIntervalKey];
    self.timeInterval = interval ? [interval intValue] : IMDefaultInterval;
    
    NSDate *dateOfNext = [[NSUserDefaults standardUserDefaults] objectForKey:IMDateOfNextLifeKey];
    self.dateOfNextLife = dateOfNext ? dateOfNext : [NSDate dateWithTimeIntervalSinceNow:self.timeInterval];
    
    NSNumber *lives = [[NSUserDefaults standardUserDefaults] objectForKey:IMLivesKey];
    self.lives = lives ? [lives intValue] : IMDefaultLives;
}

-(void)archiveProperties
{
    [[NSUserDefaults standardUserDefaults] setObject:self.dateOfNextLife forKey:IMDateOfNextLifeKey];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.timeInterval) forKey:IMTimeIntervalKey];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.lives) forKey:IMLivesKey];
}

@end