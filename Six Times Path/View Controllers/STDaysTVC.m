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
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
//		STSettingsTVC *settingsTVC			= segue.destinationViewController;
//		settingsTVC.managedObjectContext	= self.managedObjectContext;
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
