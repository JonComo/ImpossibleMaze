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
    
    if (self.updateUI) self.updateUI();
}

-(void)handleApplicationBecameActive
{
    self.interval = [self archivedInterval];
    self.lives = [self archivedLives];
    self.dateOfNextLife = [self archivedDateOfNextLife];
    
    [self assignLivesGainedWhileClosed];
    
    [timerLives invalidate];
    timerLives = nil;
    timerLives = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeLeftUntilNext) userInfo:nil repeats:YES];
    
    if (self.updateUI) self.updateUI();
}

-(void)handleApplicationBecameInactive
{
    [timerLives invalidate];
    timerLives = nil;
    
    [self saveLives];
}

-(void)assignLivesGainedWhileClosed
{
    self.dateSaved = [[NSUserDefaults standardUserDefaults] objectForKey:IMLivesManagerDateSavedKey];
    
    if (self.dateSaved && self.dateOfNextLife){
        int secondsDifference = [self.dateOfNextLife timeIntervalSinceDate:self.dateSaved];
        if (secondsDifference > 0){
            //still some time to go
            
        }else{
            self.lives += ceil(-secondsDifference / self.interval);
        }
        
        [self saveLives]; //also archives date so we dont accidently repeat process
    }
}

-(void)timeLeftUntilNext
{
    self.secondsUntilNextLife = [self.dateSaved timeIntervalSinceDate:self.dateOfNextLife];
    
    if (self.secondsUntilNextLife <= 0){
        self.lives ++;
        
        self.dateOfNextLife = [NSDate dateWithTimeIntervalSinceNow:self.interval];
    }
    
    if (self.updateUI) self.updateUI();
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

-(NSDate *)archivedDateOfNextLife
{
    NSDate *futureDate = [[NSUserDefaults standardUserDefaults] objectForKey:IMLivesManagerDateNextLifeKey];
    if (futureDate){
        return futureDate;
    }else{
        futureDate = [NSDate dateWithTimeIntervalSinceNow:self.interval];
        [[NSUserDefaults standardUserDefaults] setObject:futureDate forKey:IMLivesManagerDateNextLifeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return futureDate;
}

-(void)saveLives
{
    [[NSUserDefaults standardUserDefaults] setObject:@(self.lives) forKey:IMLivesManagerLivesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:IMLivesManagerDateSavedKey];

    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end