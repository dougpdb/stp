//
//  STPreviousDayTVC.m
//  Six Times Path
//
//  Created by Doug on 1/14/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "STPreviousDayTVC.h"
#import "Day+ST.h"
#import "LESixOfDay+ST.h"
#import "NSDate+ST.h"
#import "STLogEntrySixOfDayTVC.h"
#import "Advice.h"
#import "TestFlight.h"

#define OUT_OF_RANGE	10000
#define GUIDELINE_LABEL_WIDTH	264
#define ACTION_LABEL_WIDTH		245

static NSInteger kFontSizeGuidelineOther	= 16;
static NSString *kFontNameGuideline			= @"Palatino";
static NSString *kAllOtherEntries		= @"All Other Entries";


@interface STPreviousDayTVC ()

@property (nonatomic, retain) IBOutlet UIBarButtonItem *feedbackButton;

- (IBAction)greatHighwayExplorerFeedback:(id)sender;



@end

@implementation STPreviousDayTVC

@synthesize tableViewSections	= _tableViewSections;

#pragma mark - init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - Getters and Setters

-(NSMutableArray *)tableViewSections
{	
	if (_tableViewSections == nil) {
		NSMutableArray *tmpSectionArray	= [NSMutableArray arrayWithObjects:kAllOtherEntries,
																		   nil];
		_tableViewSections	= tmpSectionArray;
	}
	
	return _tableViewSections;
}


#pragma mark - View Loading and Appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	self.countOfTheSixWithoutUserEntries	= OUT_OF_RANGE;
	
	self.remainingScheduledEntries			= [self.thisDay getTheSixWithoutUserEntriesSorted];
	self.updatedEntries						= [self.thisDay getTheSixThatHaveUserEntriesSorted];

	
//	self.navigationItem.rightBarButtonItem	= self.feedbackButton;

}

-(void)viewWillAppear:(BOOL)animated
{

	self.title		= self.thisDay.date.shortWeekdayAndDate;
	[self setUpdatedAndRemainingScheduledEntries];
	[self.tableView reloadData];

}

-(void)viewWillDisappear:(BOOL)animated
{
	self.showAllEntries					= YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View Structure


#pragma mark - Table view data source



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self performSegueWithIdentifier:@"Guideline Entry" sender:self];
}


#pragma mark - UI Interactions

- (IBAction)greatHighwayExplorerFeedback:(id)sender {
	//	[TestFlight openFeedbackView];
}



- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
