//
//  STSecondViewController.m
//  Six Times Path
//
//  Created by ICE - Doug on 6/20/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STSecondViewController.h"

@interface STSecondViewController ()

@end

@implementation STSecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
