//
//  STDaysTVC.m
//  Six Times Path
//
//  Created by Doug on 8/7/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STDaysTVC.h"
#import "STDayTVC.h"
#import "Day+ST.h"
#import "NSDate+ST.h"
#import "Advice.h"
#import "LESixOfDay+ST.h"
#import "STSettingsTVC.h"


@interface STDaysTVC ()

@end

@implementation STDaysTVC

@synthesize managedObjectContext								= __managedObjectContext;
@synthesize fetchedResultsController							= __fetchedResultsController;

@synthesize days												= _days;
@synthesize mostRecentlyAddedDate								= _mostRecentlyAddedDate;
@synthesize followedAdvice										= _followedAdvice;
@synthesize debug												= _debug;
@synthesize orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay	= _orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay;


#pragma mark - View loading and appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.debug  = YES; // turn on debugging
	
	if (self.debug)
		NSLog(@"In viewWillAppear in STDaysTVC.m and debugging is on.");
    
    // TEMP
//    self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay  = 0;
    
	// Fetch the Advice that is currently being followed by the user and store in self.followedAdvice
	[self setupAdviceFetchedResultsController];
	
	// Fetch the Days that have been added and store in self.days.
	// Derive values and store in self.mostRecentlyAddedDate and self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay
	[self setupDaysFetchedResultsController];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Core Data Setup
-(void)setupDaysFetchedResultsController
{
	if (self.debug)
		NSLog(@"Preparing to setup the fetchedResultsController for Days.");
	
    // 1 - Decide what Entity you want
    NSString *entityName = @"Day";
    if (self.debug)   
        NSLog(@"entityName: %@", entityName);
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // 3 - Filter it if you want
    // REMEMBER: When comparing a collection (like practicedWithinTradition), you need to either use a collection comparator (CONTAINS), or use a predicate modifier (ANY/ALL/SOME, etc).
    // request.predicate = [NSPredicate predicateWithFormat:@"containedWithinSetOfAdvice.orderNumberInFollowedSets > 0", [NSNumber numberWithBool:YES]];
    
    // 4 - Sort it if you want
    request.sortDescriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:@"date"
                                                                                      ascending:NO
                                                                                       selector:@selector(localizedCaseInsensitiveCompare:)], nil];
    
    // 5 - Fetch it
    // Set attribute name to sectionNameKeyPath
    self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
																			managedObjectContext:self.managedObjectContext
																			  sectionNameKeyPath:nil
																					   cacheName:nil];
    [self performFetch];
	
	// Store the results as days
	self.days						= self.fetchedResultsController.fetchedObjects;
	
	// check to see if any days have been added
	if ([self.fetchedResultsController.fetchedObjects count] == 0) {
		if (self.debug)
			NSLog(@"0 days have been fetched. There isn't a mostRecentlyAddedDate");
	} else {
		// Set most recent day
		Day *mostRecentDay						= [self.fetchedResultsController.fetchedObjects objectAtIndex:0];
		LESixOfDay *lastTheSixOfMostRecentDay	= [[mostRecentDay getTheSixSorted] lastObject];
		self.mostRecentlyAddedDate				= mostRecentDay.date;
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = [self.followedAdvice indexOfObject:lastTheSixOfMostRecentDay.advice] + 1;
		if (self.debug) {
			NSLog(@"Most recent date: %@", self.mostRecentlyAddedDate.date);
			NSLog(@"lastTheSixOfMostRecentDay: %@", lastTheSixOfMostRecentDay.advice.name);
			NSLog(@"Index of that advice: %i", [self.followedAdvice indexOfObject:lastTheSixOfMostRecentDay.advice]);
			NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
		}
	}
	if (self.debug)
		NSLog(@"The setup for the Days fetchedResultsController is successful.");
}

-(void)setupAdviceFetchedResultsController
{
	if (self.debug)
		NSLog(@"Preparing to setup the fetchedResultsController for Advice.");
	
    // 1 - Decide what Entity you want
    NSString *entityName = @"Advice";
    
    // 2 - Request that Entity
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    // 3 - Filter it if you want
    // REMEMBER: When comparing a collection (like practicedWithinTradition), you need to either use a collection comparator (CONTAINS), or use a predicate modifier (ANY/ALL/SOME, etc).
    request.predicate = [NSPredicate predicateWithFormat:@"containedWithinSetOfAdvice.orderNumberInFollowedSets > 0", [NSNumber numberWithBool:YES]];
    
    // 4 - Sort it if you want
    request.sortDescriptors = [NSArray arrayWithObjects:
                               [NSSortDescriptor sortDescriptorWithKey:@"containedWithinSetOfAdvice.orderNumberInFollowedSets"
                                                             ascending:YES
                                                              selector:@selector(localizedCaseInsensitiveCompare:)],
                               [NSSortDescriptor sortDescriptorWithKey:@"orderNumberInSet"
                                                             ascending:YES],
                               nil];
    
    // 5 - Fetch it
    // Set attribute name to sectionNameKeyPath
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:@"containedWithinSetOfAdvice.name"
                                                                                   cacheName:nil];
    [self performFetch];
    self.followedAdvice	= [NSMutableArray arrayWithArray:self.fetchedResultsController.fetchedObjects];

	if (self.debug) {
		NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
		NSLog(@"The count of the advice that is currently being followed is %i", [self.followedAdvice count]);
		NSLog(@"The setup for the Days fetchedResultsController is successful.");
	}
}


#pragma mark - Core Data Add Records

-(void)addDay:(id)sender
{
	if (self.debug)
		NSLog(@"At start of addDay:");

    // Date to be added
	// Today
	NSDate *now					= [NSDate date];
    	
//temp disable
//	// Only allow one Day for each unique date (time agnostic)
//	if ([self.mostRecentlyAddedDate.date compare:now.date] == NSOrderedSame) {
//		[self showSimpleAlert:@"Log Entries have been already created for today."];
//		return;
//	}
	
	Day *newDay					= [NSEntityDescription insertNewObjectForEntityForName:@"Day"
                                                inManagedObjectContext:self.managedObjectContext];
	
    newDay.date					= now;
	self.mostRecentlyAddedDate	= newDay.date;
	if (self.debug)
		NSLog(@"A new Day has been created. Its date is %@. The most recently added date is %@.", newDay.date, self.mostRecentlyAddedDate);
	
	[self setTheSixAdvicesFor:newDay withIndexOfFirstFollowedAdvice:self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay inManagedObjectContext:self.managedObjectContext];
    
    [self.managedObjectContext save:nil];
    [self performFetch];
    [self.tableView reloadData];
    
    if (self.debug) {
		NSLog(@"newDay.date = %@", [newDay.date date]);
		NSLog(@"Fetch performed. Number of objects fetched: %u", [self.fetchedResultsController.fetchedObjects count]);
    }

}

-(void)setTheSixAdvicesFor:(Day *)day withIndexOfFirstFollowedAdvice:(NSInteger)indexOfFirstFollowedAdvice inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	int indexOfFollowedAdviceForTheDay;
	
	// Check to see if the index of the first followed Advice that was passed into the method exceeds the index limit of the followedAdvice array and reset as necessary
	
	if (indexOfFirstFollowedAdvice >= [self.followedAdvice count])
		indexOfFirstFollowedAdvice = 0;

    
    // Starting with the first advice to be followed for the day, cycle through the advice that has been
	// selected to be followed and add 6 advices to LogEntries that will be added to a day.
    for (int followedAdviceIncrement=0; followedAdviceIncrement<6; followedAdviceIncrement++) {
        indexOfFollowedAdviceForTheDay = followedAdviceIncrement + indexOfFirstFollowedAdvice;
		
		if (self.debug)
			NSLog(@"indexOfFollowedAdviceForTheDay: %i", indexOfFollowedAdviceForTheDay);
        
        if (indexOfFollowedAdviceForTheDay==[self.followedAdvice count] - 1)
        {
            // reset to the beginning
            indexOfFirstFollowedAdvice = -1 - followedAdviceIncrement;
			
			if (self.debug)
				NSLog(@"indexOfFirstFollowedAdvice has been reset. Value is now: %i", indexOfFirstFollowedAdvice);
        }
        
		// Add the advice to a log entry
		Advice *advice			= [self.followedAdvice objectAtIndex:indexOfFollowedAdviceForTheDay];
		
		// orderNumber range will be 1-6
		NSInteger orderNumber	= followedAdviceIncrement+1;
		
		// Create a log entry for the Six of the Day and initiate it with advice, and order number, and the day -- add to the managedObjectContext
		LESixOfDay *logEntry	= [LESixOfDay logEntryWithAdvice:advice withOrderNumber:orderNumber onDay:day inManagedObjectContext:managedObjectContext];
		
		if (self.debug)
			[logEntry logValuesOfLogEntry];
		
		// Add the log entry to the day
		[day addTheSixObject:logEntry];

		// TEMP
		// 
		self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay = indexOfFollowedAdviceForTheDay;
	}
	
	// Increment up 1 for the next day to be created
	self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay++;

	// Set the notifications
	for (LESixOfDay *logEntry in day.theSix) {
		[self addNotification:logEntry];
	}
	
	
	if (self.debug)
		NSLog(@"The next starting orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay will be %i", self.orderNumberOfFirstFollowedAdviceToBeLoggedForTheDay);
}




#pragma mark - Alerts
- (void)showSimpleAlert:(NSString *)message
{
	NSLog(@"In dialogSimpleAction:");
	
	// open a dialog with just an OK button
	UIActionSheet *actionSheet		= [[UIActionSheet alloc] initWithTitle:message
															  delegate:self
													 cancelButtonTitle:nil
												destructiveButtonTitle:@"OK"
													 otherButtonTitles:nil];
	actionSheet.actionSheetStyle	= UIActionSheetStyleDefault;
	[actionSheet showInView:self.view];	// show from our table view (pops up in the middle of the table)
}



#pragma mark - Notification
- (void)addNotification:(LESixOfDay *)sixOfDayLogEntry {
	NSDictionary *userInfo	= @{
		@"logEntryTimeScheduled"	: sixOfDayLogEntry.timeScheduled.timeAndDate,
		@"logEntryAdviceText"		: sixOfDayLogEntry.advice.name
	};
	
	NSLog(@"userInfo dictionary, %@", userInfo);
	
    UILocalNotification *localNotification = [[UILocalNotification alloc] init]; //Create the localNotification object
    
	localNotification.fireDate						= sixOfDayLogEntry.timeScheduled; //Set the date when the alert will be launched using the date adding the time the user selected on the timer
    localNotification.alertAction					= @"OK";							//The button's text that launches the application and is shown in the alert
	localNotification.alertBody						= sixOfDayLogEntry.advice.name;		//Set the message in the notification from the textField's text
    localNotification.hasAction						= YES;								//Set that pushing the button will launch the application
    localNotification.applicationIconBadgeNumber	= [[UIApplication sharedApplication] applicationIconBadgeNumber]+1; //Set the Application Icon Badge Number of the application's icon to the current Application Icon Badge Number plus 1
	localNotification.soundName						= UILocalNotificationDefaultSoundName;
	localNotification.userInfo						= userInfo;
	
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification]; //Schedule the notification with the system
	//    [alertNotification setHidden:NO]; //Set the alertNotification to be shown showing the user that the application has registered the local notification
}




#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Add Tradition Segue"]) {
//        NSLog(@"Setting STTRaditionsFollowedTVC as a delegate of STAddTraditionTVC.");
//        
//        STAddTraditionTVC *addTraditionTVC  = segue.destinationViewController;
//        addTraditionTVC.delegate            = self;
//        addTraditionTVC.managedObjectContext= self.managedObjectContext;
    } else if ([segue.identifier isEqualToString:@"Role Detail Segue"]) {
        NSLog(@"Setting STTraditionsFollowedTVC as a delegate of STTraditionDetailTVC.");
//        STTraditionDetailTVC *traditionDetailTVC        = segue.destinationViewController;
//        traditionDetailTVC.delegate                     = self;
//        traditionDetailTVC.managedObjectContext         = self.managedObjectContext;
//        
//        // Store the selected SpiritualTradition in selectedTradition property
//        NSIndexPath *indexPath  = [self.tableView indexPathForSelectedRow];
//        self.selectedTradition  = [self.fetchedResultsController objectAtIndexPath:indexPath];
//        
//        NSLog(@"Passing selected role (%@} to STTraditionDetailTVC.", self.selectedTradition.name);
//        traditionDetailTVC.tradition    = self.selectedTradition;
    } else if ([segue.identifier isEqualToString:@"viewDayDetail"]) {
        if (self.debug)
			NSLog(@"Segue triggered: viewDayDetail to %@", segue.destinationViewController);
        STDayTVC *dayTVC			= segue.destinationViewController;
        dayTVC.managedObjectContext	= self.managedObjectContext;
        
        // Store the selected SpiritualTradition in selectedTradition property
        NSIndexPath *indexPath		= [self.tableView indexPathForSelectedRow];
        self.selectedDay			= [self.fetchedResultsController objectAtIndexPath:indexPath];
		
        NSLog(@"Passing selected role (%@} to STSetOfAdviceTVC.", self.selectedDay.date.date);
        dayTVC.selectedDay			= self.selectedDay;
        
    } else if ([segue.identifier isEqualToString:@"settingsSegue"]) {
		if (self.debug)
			NSLog(@"Segue triggered: settingsSegue");
		STSettingsTVC *settingsTVC			= segue.destinationViewController;
		settingsTVC.managedObjectContext	= self.managedObjectContext;
	} else  {
        NSLog(@"Unidentified segue attempted!");
    }
}



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"dateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Day *day					= [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text			= [NSString stringWithFormat:@"%@ %@", [day.date date], [day.date time]];
	
	// Sort the six
	NSArray *theSixSorted		= [day getTheSixSorted];

	// Get a string of all the advice concatenated
	NSString *listOfAdvice		= [[NSString alloc] init];
	
	for (LESixOfDay *logEntry in theSixSorted) {
		listOfAdvice			= [listOfAdvice stringByAppendingFormat:@"%@. ", logEntry.advice.name];
		if (self.debug)
			NSLog(@"logEntry.advice.name: %@", logEntry.advice.name);
	}
	cell.detailTextLabel.text	= listOfAdvice;

	if (self.debug)
		NSLog(@"%@",listOfAdvice);
    
    return cell;
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
