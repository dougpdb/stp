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
#import "UIFont+ST.h"
#import "TestFlight.h"

@interface STPreviousDaysTVC ()
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property BOOL performFetchAfterViewDidLoad;


-(void)setupDaysFetchedResultsController;

@end

@implementation STPreviousDaysTVC


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
	
	[self setupDaysFetchedResultsController];
	self.days	= [NSArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
	self.performFetchAfterViewDidLoad = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(preferredContentSizeChanged:)
												 name:UIContentSizeCategoryDidChangeNotification
											   object:nil];
	
}


- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
	NSLog(@"in viewWillAppear");
	
	if (self.performFetchAfterViewDidLoad) {
		NSLog(@"going to fetch after view did load.");
		[self performFetch];
		self.days = [NSArray arrayWithArray:self.fetchedResultsController.fetchedObjects];
		[self.tableView reloadData];
	}
}

-(void)viewWillDisappear:(BOOL)animated {
	self.performFetchAfterViewDidLoad = YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Core Data Setup
-(void)setupDaysFetchedResultsController
{
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UILabel *placeholderLabel = [UILabel new];
	placeholderLabel.font = [UIFont preferredFontForUILabel];
	
	return placeholderLabel.font.pointSize * 1.3 + 22;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *cellIdentifier	= @"day";
		
	UITableViewCell *cell		= [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	
	Day *day					= (indexPath.section == 0) ? [self.days objectAtIndex:indexPath.row + 1] : [self.fetchedResultsController  objectAtIndexPath:indexPath];										// use +1 to "skip" today
	
	cell.textLabel.font = [UIFont preferredFontForUILabel];
	cell.detailTextLabel.font = [UIFont preferredFontForUILabel];
	
	cell.textLabel.text			= day.date.shortWeekdayAndDate;
	cell.detailTextLabel.text	= [NSString stringWithFormat:@"%lu Entries", (unsigned long)[[day getTheSixThatHaveUserEntriesSorted] count]];

	return cell;
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[TestFlight passCheckpoint:@"GO TO PREVIOUS DAY"];
	NSIndexPath *indexPath				= [self.tableView indexPathForSelectedRow];
		
	STPreviousDayTVC *previousDay		= segue.destinationViewController;
	NSLog(@"Previous Day object created");
	previousDay.managedObjectContext	= self.managedObjectContext;
	NSLog(@"The managed object has been set");
	previousDay.thisDay					= (indexPath.section == 0) ? [self.days objectAtIndex:indexPath.row +1] : [self.fetchedResultsController objectAtIndexPath:indexPath];
	NSLog(@"This day has been set");

}
- (IBAction)greatHighwayExplorerFeedback:(id)sender {
	//	[TestFlight openFeedbackView];
}
@end
