//
//  IMLivesManager.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/10/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMLivesManager.h"

static int INITIAL_LIVES = 5;
static int INITIAL_INTERVAL = 30;

static NSString *IMLivesManagerLivesKey = @"lives";
static NSString *IMLivesManagerIntervalKey = @"lives";

static NSString *IMLivesManagerDateSavedKey = @"dateSaved";
static NSString *IMLivesManagerDateNextLifeKey = @"nextLife";

@implementation IMLivesManager
{
    NSTimer *timerLives;
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
    }
    
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setLives:(int)lives
{
    _lives = lives;
    
    if (self.livesChangedHandler) self.livesChangedHandler(lives);
}

-(void)handleApplicationBecameActive
{
    self.interval = [self archivedInterval];
    self.lives = [self archivedLives]; //get archived lives
    
    [self assignLivesGainedWhileClosed];
    
    [timerLives invalidate];
    timerLives = nil;
    timerLives = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownInterval) userInfo:nil repeats:YES];
    
    if (self.secondsChangedHandler) self.secondsChangedHandler(self.secondsUntilNextLife);
}

-(void)handleApplicationBecameInactive
{
    [timerLives invalidate];
    timerLives = nil;
    
    [self saveLives];
}

-(void)assignLivesGainedWhileClosed
{
    NSDate *dateSaved = [[NSUserDefaults standardUserDefaults] objectForKey:IMLivesManagerDateSavedKey];
    
    if (dateSaved){
        int secondsClosed = [[NSDate date] timeIntervalSinceDate:dateSaved];
        
        self.lives += ceil(secondsClosed / self.interval);
        
        [self saveLives]; //also archives date so we dont accidently repeat process
    }
}

-(void)countDownInterval
{
    self.secondsUntilNextLife --;
    
    if (self.secondsUntilNextLife <= 0){
        self.lives ++;
        self.secondsUntilNextLife = self.interval;
    }
    
    if (self.secondsChangedHandler) self.secondsChangedHandler(self.secondsUntilNextLife);
}

-(int)archivedLives
{
    NSNumber *storedLives = [[NSUserDefaults standardUserDefaults] objectForKey:IMLivesManagerLivesKey];
    if (storedLives){
        return [storedLives intValue];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@(INITIAL_LIVES) forKey:IMLivesManagerLivesKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return INITIAL_LIVES;
}

-(int)archivedInterval
{
    NSNumber *storedInterval = [[NSUserDefaults standardUserDefaults] objectForKey:IMLivesManagerIntervalKey];
    if (storedInterval){
        return [storedInterval intValue];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@(INITIAL_INTERVAL) forKey:IMLivesManagerIntervalKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return INITIAL_INTERVAL;
}

-(void)saveLives
{
    [[NSUserDefaults standardUserDefaults] setObject:@(self.lives) forKey:IMLivesManagerLivesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:IMLivesManagerDateSavedKey];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end