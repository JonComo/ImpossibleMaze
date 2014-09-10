//
//  RRAudioPlayer.m
//  RatRace
//
//  Created by Jon Como on 9/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "RRAudioPlayer.h"

#import "RRAudioEngine.h"

@implementation RRAudioPlayer
{
    NSTimer *fadeTimer;
    
    float fadeTime;
}

-(BOOL)shouldMute
{
    BOOL muteMusic = [[NSUserDefaults standardUserDefaults] boolForKey:MUTE_MUSIC];
    
    if (muteMusic && self.numberOfLoops == -1)
    {
        return YES;
    }else{
        return NO;
    }
}

-(void)fadeIn:(float)time
{
    if ([self shouldMute])
    {
        self.volume = 0;
        return;
    }
    
    [fadeTimer invalidate];
    fadeTimer = nil;
    
    fadeTime = time;
    
    fadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeInStep) userInfo:nil repeats:YES];
}

-(void)fadeOut:(float)time
{
    if ([self shouldMute])
    {
        self.volume = 0;
        return;
    }
    
    [fadeTimer invalidate];
    fadeTimer = nil;
    
    fadeTime = time;
    
    fadeTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fadeOutStep) userInfo:nil repeats:YES];
}

-(void)fadeInStep
{
    self.volume += 1/(fadeTime*10);
    if (self.volume >= 1)
    {
        [fadeTimer invalidate];
    }
}

-(void)fadeOutStep
{
    self.volume -= 1/(fadeTime*10);
    if (self.volume <= 0)
    {
        [fadeTimer invalidate];
    }
}

@end
