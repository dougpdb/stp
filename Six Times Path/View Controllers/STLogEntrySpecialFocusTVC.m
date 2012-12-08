//
//  STLogEntrySpecialFoucsTVC.m
//  Six Times Path
//
//  Created by Doug on 10/1/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STLogEntrySpecialFocusTVC.h"

@interface STLogEntrySpecialFocusTVC ()

@end

@implementation STLogEntrySpecialFocusTVC

@synthesize fetchedResultsController	= _fetchedResultsController;
@synthesize managedObjectContext		= _managedObjectContext;

@synthesize leSpecialFocus	= _leSpecialFocus;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
