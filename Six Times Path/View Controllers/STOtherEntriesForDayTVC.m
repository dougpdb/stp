//
//  STOtherEntriesForDayTVC.m
//  Six Times Path
//
//  Created by Doug on 12/13/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STOtherEntriesForDayTVC.h"
#import "Advice.h"
#import "Day+ST.h"
#import "NSDate+ST.h"
#import "LESixOfDay.h"

@interface STOtherEntriesForDayTVC ()

@end

@implementation STOtherEntriesForDayTVC

@synthesize managedObjectContext		= _managedObjectContext;
@synthesize fetchedResultsController	= _fetchedResultsController;

@synthesize selectedDay					= _selectedDay;
@synthesize showGuidelinesWithoutEntries=_showGuidelinesWithoutEntries;


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
