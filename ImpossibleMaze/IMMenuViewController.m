//
//  IMMenuViewController.m
//  ImpossibleMaze
//
//  Created by Jon Como on 9/7/14.
//  Copyright (c) 2014 Como. All rights reserved.
//

#import "IMMenuViewController.h"

#import "IMMazeViewController.h"

#import "RRAudioEngine.h"
#import "IMLivesManager.h"

@interface IMMenuViewController ()

@end

@implementation IMMenuViewController
{
    __weak IBOutlet UILabel *labelLives;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //[[RRAudioEngine sharedEngine] playSoundNamed:@"soundtrack" extension:@"wav" loop:YES];
    
    [IMLivesManager sharedManager].valuesChanged = ^(void){
        labelLives.text = [NSString stringWithFormat:@"Lives: %i Next: %.0fs", [IMLivesManager sharedManager].lives, [IMLivesManager sharedManager].secondsUntilNextLife];
    };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)play:(id)sender
{
    if ([IMLivesManager sharedManager].lives <= 0) return;
    
    IMMazeViewController *mazeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mazeVC"];
    mazeVC.mazeSize = CGSizeMake(12, 12);
    [self presentViewController:mazeVC animated:NO completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
