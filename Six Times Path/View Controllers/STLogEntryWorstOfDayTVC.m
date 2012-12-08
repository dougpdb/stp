//
//  STLogEntryWorstOfDayTVC.m
//  Six Times Path
//
//  Created by Doug on 10/1/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STLogEntryWorstOfDayTVC.h"

@interface STLogEntryWorstOfDayTVC ()

@end

@implementation STLogEntryWorstOfDayTVC

@synthesize fetchedResultsController	= _fetchedResultsController;
@synthesize managedObjectContext		= _managedObjectContext;


@synthesize leWorstOfDay	= _leWorstOfDay;


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
