//
//  STPreviousDaysTVC.m
//  Six Times Path
//
//  Created by Doug on 1/4/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "STPreviousDaysTVC.h"
#import "STPreviousDayTVC.h"
#import "Day+ST.h"
#import "NSDate+ST.h"

@interface STPreviousDaysTVC ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;


-(void)setupDaysFetchedResultsController;

@end

@implementation STPreviousDaysTVC

@synthesize managedObjectContext		= __managedObjectContext;
@synthesize fetchedResultsController	= __fetchedResultsController;

@synthesize days						= _days;
@synthesize dateFormatter				= _dateFormatter;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	NSLog(@"Previous days has loaded.");
	
	[self setupDaysFetchedResultsController];
	self.days	= [NSArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
	
	NSLog(@"There are %i previous days.", [self.days count]);
}

-(void)viewWillAppear
{
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Core Data Setup
-(void)setupDaysFetchedResultsController
{
    
	NSLog(@"In setupDaysFetchedResultsController");
	
	// Set request with sorting, then fetch
	NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:@"Day"];
    request.sortDescriptors			= @[[NSSortDescriptor sortDescriptorWithKey:@"date"
																ascending:NO]];
	self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:@"date.monthAndYear"
																				   cacheName:nil];
    [self performFetch];
}

#pragma mark - Table View Structure

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
		return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects] -1;
	else {
		return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
	}
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier	= @"day";
		
	UITableViewCell *cell		= [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	
	Day *day					= (indexPath.section == 0) ? [self.days objectAtIndex:indexPath.row + 1] : [self.fetchedResultsController  objectAtIndexPath:indexPath];										// use +1 to "skip" today
	
	cell.textLabel.text			= day.date.shortWeekdayAndDate;
	cell.detailTextLabel.text	= [NSString stringWithFormat:@"%i Entries", [[day getTheSixThatHaveUserEntriesSorted] count]];

	//	[[Crashlytics sharedInstance] crash];

	return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
	
	NSLog(@"Segue identifier is %@", segue.identifier.description);
	
	STPreviousDayTVC *previousDay		= segue.destinationViewController;
	previousDay.managedObjectContext	= self.managedObjectContext;
	previousDay.thisDay					= (indexPath.section == 0) ? [self.days objectAtIndex:indexPath.row +1] : [self.fetchedResultsController objectAtIndexPath:indexPath];
	
}
@end
