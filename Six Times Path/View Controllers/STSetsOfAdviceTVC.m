//
//  STTraditionsFollowedTVC.m
//  Six Times Path
//
//  Created by ICE - Doug on 6/28/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STSetsOfAdviceTVC.h"
#import "STSetOfAdviceTVC.h"
#import "STAddFollowingSetOfAdviceTVC.h"
#import "SpiritualTradtion.h"
#import "Advice.h"
#import "Day+ST.h"
#import "LESixOfDay+ST.h"
//#import "TestFlight.h"
#import "SetOfAdvice.h"
#import "STNotificationController.h"


#define SET_OF_ADVICE_LABEL_WIDTH	274
#define GUIDELINE_LABEL_WIDTH		264

@interface STSetsOfAdviceTVC ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL isFilteredForFollowingSetsOfAdvice;

@property (nonatomic) NSArray *allSetsOfAdvice;
@property (nonatomic) NSMutableArray *selectedSetsOfAdvice;
@property (nonatomic) NSArray *followingSetsOfAdvice;
@property (nonatomic) NSArray *preEditFollowingSetsOfAdvice;
@property (nonatomic) NSArray *notFollowingSetsOfAdvice;
@property (nonatomic) NSArray *allAdviceBeingFollowed;

@property (nonatomic, strong) STNotificationController *notificationController;

@end

@implementation STSetsOfAdviceTVC



#pragma mark - View loading and appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.notificationController				= [STNotificationController new];

	[self setupAllSetsOfAdviceFetchedResultsController];
	self.allSetsOfAdvice					= self.fetchedResultsController.fetchedObjects;
	
	[self refreshFollowingSetsOfAdvice];
	
	NSLog(@"count of following SetOfAdvice: %i", [self.followingSetsOfAdvice count]);
	NSLog(@"count of NOT following SetOfAdvice: %i", [self.notFollowingSetsOfAdvice	count]);
	
	if ([self.followingSetsOfAdvice count] == 0) {
		[self setEditFollowingSetsOfAdviceButtons];
	}

	self.preEditFollowingSetsOfAdvice		= [self.followingSetsOfAdvice copy];
	
	[self initSetOfAdviceSegmentedControlFilter];
	if ([self.followingSetsOfAdvice count] > 0) {
		[self setViewFollowingSetsOfAdviceButtons];
		[self.tableView reloadData];
	} else {
		[self editFollowingSetsOfGuidelines:nil];
	}
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.selectedSetsOfAdvice	= nil;
	self.allSetsOfAdvice		= nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.selectedSetsOfAdvice	= [[NSMutableArray alloc] init];
	//	[self updateSelectedSetsOfAdvice];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Core Data Setup
-(void)setupAllSetsOfAdviceFetchedResultsController
{
	NSString *entityName			= @"SetOfAdvice";
	NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:entityName];
	request.sortDescriptors			= @[[NSSortDescriptor sortDescriptorWithKey:@"practicedWithinTradition.name"
																ascending:YES
																 selector:@selector(localizedCaseInsensitiveCompare:)],
							   [NSSortDescriptor sortDescriptorWithKey:@"name"
															 ascending:YES
															  selector:@selector(localizedCaseInsensitiveCompare:)]];
	self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
}

-(void)refreshFollowingSetsOfAdvice
{
	self.allAdviceBeingFollowed				= nil;

	NSPredicate *predicate;
	predicate								= [NSPredicate predicateWithFormat:@"self.orderNumberInFollowedSets > 0"];
	NSArray *unsortedfollowingSetsOfAdvice	= [self.allSetsOfAdvice filteredArrayUsingPredicate:predicate];
	NSArray *sortDescriptors				= @[[[NSSortDescriptor alloc] initWithKey:@"orderNumberInFollowedSets" ascending:YES]];
	self.followingSetsOfAdvice				= [unsortedfollowingSetsOfAdvice sortedArrayUsingDescriptors:sortDescriptors];

	predicate								= [NSPredicate predicateWithFormat:@"self.orderNumberInFollowedSets == %@ or self.orderNumberInFollowedSets == 0", [NSNull null]];
	self.notFollowingSetsOfAdvice			= [self.allSetsOfAdvice filteredArrayUsingPredicate:predicate];
}

-(NSArray *)allAdviceBeingFollowed
{
	if (_allAdviceBeingFollowed == nil) {
		NSMutableArray *allAdvice			= [[NSMutableArray alloc] init];
		for (SetOfAdvice *followedSetOfAdvice in self.followingSetsOfAdvice) {
			NSArray *unsortedAdvice			= [followedSetOfAdvice.containsAdvice allObjects];				
			NSArray *sortDescriptors		= @[[[NSSortDescriptor alloc] initWithKey:@"orderNumberInSet" ascending:YES]];
			NSArray *sortedAdvice			= [unsortedAdvice sortedArrayUsingDescriptors:sortDescriptors];
			
			[allAdvice addObjectsFromArray:sortedAdvice];
		}
		_allAdviceBeingFollowed				= [NSArray arrayWithArray:allAdvice];
	}
	return _allAdviceBeingFollowed;
}


#pragma mark - Navigation Item Buttons and Actions

-(void)setViewFollowingSetsOfAdviceButtons
{
	self.navigationItem.leftBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Done"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(returnToDay:)];
	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																						   target:self
																						   action:@selector(editFollowingSetsOfGuidelines:)];
}

-(void)setEditFollowingSetsOfAdviceButtons
{
	self.navigationItem.leftBarButtonItem	= nil;
	self.navigationItem.rightBarButtonItem	= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																						   target:self
																						   action:@selector(endEditFollowingSetsOfGuidelines:)];
		
	[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:YES];
}

-(void)setViewAllSetsOfAdviceButtons
{
	self.navigationItem.leftBarButtonItem	= [[UIBarButtonItem alloc] initWithTitle:@"Done"
																			 style:UIBarButtonItemStyleBordered
																			target:self
																			action:@selector(returnToDay:)];
	self.navigationItem.rightBarButtonItem	= nil; // [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//																						  target:self
//																						  action:@selector(addNewSetOfGuidelines:)];
	[self.tableView reloadData];
}

-(void)setEditAllSetsOfAdviceButtons
{
	
}

-(void)returnToDay:(id)sender
{
	if (![self.followingSetsOfAdvice isEqualToArray:self.preEditFollowingSetsOfAdvice])
		[self resetFollowedEntries];
	
	[self.navigationController popToRootViewControllerAnimated:YES];
	[self.tableView setEditing:NO animated:YES];
}


#pragma mark - Resetting Advice Being Followed

-(BOOL)currentlyFollowingAdvice:(Advice *)advice
{
	return ([self.allAdviceBeingFollowed indexOfObject:advice] == NSNotFound) ? NO : YES;
}

-(void)resetFollowedEntries
{

	NSArray *remainingScheduledEntries			= [self.currentDay getTheSixWithoutUserEntriesSorted];
	
	if ([remainingScheduledEntries count] > 0) {
		
		[self.notificationController cancelAllNotifications];
		
		NSMutableArray *newFollowedEntries		= [[NSMutableArray alloc] init];
		[newFollowedEntries addObjectsFromArray:[self.currentDay getTheSixThatHaveUserEntriesSorted]];
		
		
		for (LESixOfDay *remainingEntry in remainingScheduledEntries) {
			if ([self currentlyFollowingAdvice:remainingEntry.advice])
				[newFollowedEntries addObject:remainingEntry];
			
			else {
				[self.currentDay removeTheSixObject:remainingEntry];
				remainingEntry.dayOfSix			= nil;
			}
		}
		
		if ([newFollowedEntries count] < 6 && [newFollowedEntries count] > 0) {
			[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:NO];
			NSInteger indexOfNewlyFollowedAdviceForTheDay;
			NSInteger orderNumber							= 0;
			
			if ([newFollowedEntries count] > [[self.currentDay getTheSixThatHaveUserEntriesSorted] count]) {
				LESixOfDay *lastEntryStillBeingFollowed		= [newFollowedEntries lastObject];
				Advice *lastAdviceStillBeingFollowed		= lastEntryStillBeingFollowed.advice;
				
				indexOfNewlyFollowedAdviceForTheDay			= [self.allAdviceBeingFollowed indexOfObject:lastAdviceStillBeingFollowed] + 1;
			} else {
				indexOfNewlyFollowedAdviceForTheDay			= 0;
			}
			

			NSMutableArray *newFollowedAdvice				= [[NSMutableArray alloc] init];
			
			for (LESixOfDay *entryStillBeingFollowed in newFollowedEntries) {
				entryStillBeingFollowed.orderNumberForType	= [NSNumber numberWithInteger:++orderNumber];
				[newFollowedAdvice addObject:entryStillBeingFollowed.advice];
			}
			
			if ([self.allAdviceBeingFollowed count] > 0) {
				while (orderNumber < 6) {
					if (indexOfNewlyFollowedAdviceForTheDay == [self.allAdviceBeingFollowed count])
						indexOfNewlyFollowedAdviceForTheDay		= 0;
					// wont work when there is 0 advice, ie no advice object at index
					Advice *advice								= [self.allAdviceBeingFollowed objectAtIndex:indexOfNewlyFollowedAdviceForTheDay++];
					
					if (![newFollowedAdvice containsObject:advice]){
						LESixOfDay *newEntry					= [LESixOfDay logEntryWithAdvice:advice
																			   withOrderNumber:++orderNumber
																						 onDay:self.currentDay
																		inManagedObjectContext:self.managedObjectContext];
						[self.currentDay addTheSixObject:newEntry];
					}
				}
			}
				[self.notificationController addNotifications:[self.currentDay getTheSixSorted]];
		}
		[self.managedObjectContext save:nil];
	}
}


#pragma mark - Editing rows

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isFilteredForFollowingSetsOfAdvice)
		if (indexPath.row < [self.followingSetsOfAdvice count])
			return UITableViewCellEditingStyleDelete;
		else
			return UITableViewCellEditingStyleInsert;
		else
			if (indexPath.row < [self.allSetsOfAdvice count])
				return UITableViewCellEditingStyleNone;			//	FUTURE: Allow user added sets of guidelines to be deleted
			else
				return UITableViewCellEditingStyleInsert;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (self.isFilteredForFollowingSetsOfAdvice)
			[self addFollowingSetsOfAdvice];
    }
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if (self.isFilteredForFollowingSetsOfAdvice)
			[self removeFollowingSetsOfAdviceAtIndexPath:indexPath];
	}
	
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isFilteredForFollowingSetsOfAdvice) {
		if (indexPath.row < [self.followingSetsOfAdvice count])
			return @"Remove";
	} else {
		return @"Delete";
	}
	return nil;
}


#pragma mark Add Set

-(void)addFollowingSetsOfAdvice
{
	[self performSegueWithIdentifier:@"addFollowingSetsOfGuidelines" sender:self];
}

-(void)addFollowingSetOfAdviceTVC:(STAddFollowingSetOfAdviceTVC *)addFollowingSetOfAdviceTVC didAddSetOfAdvice:(SetOfAdvice *)setOfAdvice
{
	NSInteger lastOrderNumberInFollowedSets		= [[(SetOfAdvice *)[self.followingSetsOfAdvice lastObject] orderNumberInFollowedSets] intValue];
	if (setOfAdvice) {
		setOfAdvice.orderNumberInFollowedSets	= [NSNumber numberWithInt:lastOrderNumberInFollowedSets + 1];
	}
	[self.managedObjectContext save:nil];
	[self refreshFollowingSetsOfAdvice];
		
	NSIndexPath *indexPath						= [NSIndexPath indexPathForRow:[self.followingSetsOfAdvice count]-1 inSection:0];
    UITableViewRowAnimation animationStyle		= UITableViewRowAnimationFade;
	[self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animationStyle];
}


#pragma mark Remove Set

-(void)removeFollowingSetsOfAdviceAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *tempFollowingSetsOfAdviceArray	= [NSMutableArray arrayWithArray:self.followingSetsOfAdvice];
	
	SetOfAdvice *setOfAdviceToRemove				= [self.followingSetsOfAdvice objectAtIndex:[indexPath indexAtPosition:1]]; // works
	setOfAdviceToRemove.orderNumberInFollowedSets	= 0;
	
	[tempFollowingSetsOfAdviceArray removeObjectIdenticalTo:setOfAdviceToRemove];
	
	for (SetOfAdvice *setOfAdvice in tempFollowingSetsOfAdviceArray) {
		setOfAdvice.orderNumberInFollowedSets		= [NSNumber numberWithInt:[tempFollowingSetsOfAdviceArray indexOfObject:setOfAdvice] + 1];
	}
	
	[self.managedObjectContext save:nil];
	[self refreshFollowingSetsOfAdvice];
	
	UITableViewRowAnimation animationStyle			= UITableViewRowAnimationFade;
	[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animationStyle];
}


#pragma mark Reorder Set

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isFilteredForFollowingSetsOfAdvice && (indexPath.row < [self.followingSetsOfAdvice count]))
		return YES;
	else
		return NO;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
	NSMutableArray *tempFollowingSetsOfAdviceArray	= [NSMutableArray arrayWithArray:self.followingSetsOfAdvice];
	
	SetOfAdvice *setOfAdviceToMove					= [tempFollowingSetsOfAdviceArray objectAtIndex:sourceIndexPath.row];
	[tempFollowingSetsOfAdviceArray removeObjectAtIndex:sourceIndexPath.row];
	[tempFollowingSetsOfAdviceArray insertObject:setOfAdviceToMove atIndex:destinationIndexPath.row];
	
	[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:NO];
	for (SetOfAdvice *setOfAdvice in tempFollowingSetsOfAdviceArray) {
		setOfAdvice.orderNumberInFollowedSets		= [NSNumber numberWithInt:[tempFollowingSetsOfAdviceArray indexOfObject:setOfAdvice] + 1];
	}
	[self setSuspendAutomaticTrackingOfChangesInManagedObjectContext:YES];
	[self refreshFollowingSetsOfAdvice];
}


-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
	if (proposedDestinationIndexPath.row >= [self.followingSetsOfAdvice count] - 1)
		return [NSIndexPath indexPathForRow:[self.followingSetsOfAdvice count] - 1 inSection:sourceIndexPath.section];
	else
		return proposedDestinationIndexPath;
}



-(NSMutableArray *)resetOrderingOfFollowedSetsOfAdvice:(NSMutableArray *)setsOfAdvice
{
	// TO DO
	return nil;
}



-(void)editFollowingSetsOfGuidelines:(id)sender
{
	[self setEditFollowingSetsOfAdviceButtons];
	[self.tableView setEditing:YES animated:YES];
	[self.tableView reloadData];					// replace this with something more visually elegant, such as inserting last row with animation
}

-(void)endEditFollowingSetsOfGuidelines:(id)sender
{
	[self.managedObjectContext save:nil];
	[self setViewFollowingSetsOfAdviceButtons];
	[self.tableView setEditing:NO animated:YES];
	[self refreshFollowingSetsOfAdvice];
	[self.tableView reloadData];					// replace this with something more visually elegant, such as deleting last row with animation
}





#pragma mark - Segmented Control Filter

-(void)initSetOfAdviceSegmentedControlFilter
{
	NSArray *buttonNames	= @[@"Following",@"All"];
	UISegmentedControl *segmentedControl	= [[UISegmentedControl alloc] initWithItems:buttonNames];
	segmentedControl.segmentedControlStyle	= UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex	= 0;
	self.isFilteredForFollowingSetsOfAdvice	= YES;
	[segmentedControl addTarget:self
						 action:@selector(setSetOfAdviceViewFilter:)
			   forControlEvents:UIControlEventValueChanged];
	
	self.navigationItem.titleView			= segmentedControl;
}

-(void)setSetOfAdviceViewFilter:(UISegmentedControl *)segmentedControl
{
	if (segmentedControl.selectedSegmentIndex == 0) {
		self.isFilteredForFollowingSetsOfAdvice	= YES;
		[self setViewFollowingSetsOfAdviceButtons];
	} else {
		self.isFilteredForFollowingSetsOfAdvice = NO;
		[self setViewAllSetsOfAdviceButtons];
	}

	[self.tableView reloadData];
}


#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSLog(@"-prepareForSegue:sender triggered.");
	if ([segue.identifier isEqualToString:@"addFollowingSetsOfGuidelines"]) {
		
		STAddFollowingSetOfAdviceTVC *addFollowingSetOfAdviceTVC	= [[segue.destinationViewController viewControllers] objectAtIndex:0];
		addFollowingSetOfAdviceTVC.delegate							= self;
		addFollowingSetOfAdviceTVC.managedObjectContext				= self.managedObjectContext;
		addFollowingSetOfAdviceTVC.notFollowingSetsOfAdvice			= self.notFollowingSetsOfAdvice;
			
	} else {
		
		NSIndexPath *indexPath					= [self.tableView indexPathForSelectedRow];
		
		STSetOfAdviceTVC *setOfAdviceTVC		= segue.destinationViewController;
		
		setOfAdviceTVC.managedObjectContext		= self.managedObjectContext;
		
		if (self.isFilteredForFollowingSetsOfAdvice)
			setOfAdviceTVC.selectedSetOfAdvice	= [self.followingSetsOfAdvice objectAtIndex:indexPath.row];
		else
			setOfAdviceTVC.selectedSetOfAdvice	= [self.allSetsOfAdvice objectAtIndex:indexPath.row];
		
	}
}


#pragma mark - Table view structure

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (self.isFilteredForFollowingSetsOfAdvice) {
		if ([tableView isEditing])
			return [self.followingSetsOfAdvice count] + 1;
		else
			return [self.followingSetsOfAdvice count];
	} else {
		if ([tableView isEditing])
			return [self.allSetsOfAdvice count] + 1;
		else
			return [self.allSetsOfAdvice count];
	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
    if ([tableView isEditing] &&
		(
		 (self.isFilteredForFollowingSetsOfAdvice && indexPath.row == [self.followingSetsOfAdvice count]) ||
		 (!self.isFilteredForFollowingSetsOfAdvice && indexPath.row == [self.allSetsOfAdvice count])
		 )
		) {
		return 44;
	} else {
		SetOfAdvice	*setOfAdvice;
		UILabel *setOfAdviceLabel		= [UILabel new];
		setOfAdviceLabel.lineBreakMode	= NSLineBreakByWordWrapping;
		setOfAdviceLabel.font			= [UIFont boldSystemFontOfSize:17];
		
		if (self.isFilteredForFollowingSetsOfAdvice)
			setOfAdvice								= [self.followingSetsOfAdvice objectAtIndex:indexPath.row];
		else
			setOfAdvice								= [self.allSetsOfAdvice objectAtIndex:indexPath.row];

		setOfAdviceLabel.text			= setOfAdvice.practicedWithinTradition.name;
		
		CGFloat guidelineLabelHeight	= [self heightForLabel:setOfAdviceLabel
												   withText:setOfAdviceLabel.text
												 labelWidth:SET_OF_ADVICE_LABEL_WIDTH];
		
		return 32 + guidelineLabelHeight + 8;		// change for landscape orientation?
		
	}
	
}

#pragma mark Managing Cell and Label Heights
-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text labelWidth:(CGFloat)labelWidth
{
	UIFont *font = label.font;
	NSAttributedString *attributedText = [ [NSAttributedString alloc]
										  initWithString:text
										  attributes: @{NSFontAttributeName: font}
										  ];
	CGRect rect = [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX}
											   options:NSStringDrawingUsesLineFragmentOrigin
											   context:nil];
	CGSize size = rect.size;
	CGFloat height = ceilf(size.height);
	//	CGFloat width  = ceilf(size.width);
	return height;
}

-(void)resizeHeightToFitForLabel:(UILabel *)label labelWidth:(CGFloat)labelWidth
{
	CGRect newFrame			= label.frame;
	newFrame.size.height	= [self heightForLabel:label withText:label.text labelWidth:labelWidth];
	label.frame				= newFrame;
}


#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEditing] &&
		(
		 (self.isFilteredForFollowingSetsOfAdvice && indexPath.row == [self.followingSetsOfAdvice count]) ||
		 (!self.isFilteredForFollowingSetsOfAdvice && indexPath.row == [self.allSetsOfAdvice count])
		 )
		) {
		static NSString *addCellIdentifier	= @"addSetOfGuidelines";
		UITableViewCell *addCell			= [tableView dequeueReusableCellWithIdentifier:addCellIdentifier];
		
		if (self.isFilteredForFollowingSetsOfAdvice && indexPath.row == [self.followingSetsOfAdvice count])
			addCell.textLabel.text			= @"Choose Set of Guidelines...";
		else
			addCell.textLabel.text			= @"Add New Set of Guidelines...";
		
		return addCell;
	} else {
		SetOfAdvice	*setOfAdvice;
		static NSString *setOfAdviceCellIdentifier	= @"setOfAdviceCell";
		UITableViewCell *setOfAdviceCell			= [tableView dequeueReusableCellWithIdentifier:setOfAdviceCellIdentifier];
		   
		UILabel *nameOfTraditionLabel				= (UILabel *)[setOfAdviceCell viewWithTag:10];
		UILabel *nameOfSetOfAdviceLabel				= (UILabel *)[setOfAdviceCell viewWithTag:11];

		if (self.isFilteredForFollowingSetsOfAdvice)
			setOfAdvice								= [self.followingSetsOfAdvice objectAtIndex:indexPath.row];
		else
			setOfAdvice								= [self.allSetsOfAdvice objectAtIndex:indexPath.row];

		nameOfTraditionLabel.text					= setOfAdvice.practicedWithinTradition.name;
		nameOfSetOfAdviceLabel.text					= setOfAdvice.name;
					
		return setOfAdviceCell;
	}
}




#pragma mark - Table view delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"row selected");
}

- (IBAction)greatHIghwayExplorerFeedback:(id)sender {
	//	[TestFlight openFeedbackView];
}
@end
