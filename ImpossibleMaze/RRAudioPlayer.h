//
//  RRAudioPlayer.h
//  RatRace
//
//  Created by Jon Como on 9/2/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface RRAudioPlayer : AVAudioPlayer

-(void)fadeIn:(float)time;
-(void)fadeOut:(float)time;

@end
