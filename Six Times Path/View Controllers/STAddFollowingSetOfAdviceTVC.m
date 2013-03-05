//
//  STAddFollowingSetOfAdviceTVC.m
//  Six Times Path
//
//  Created by Doug on 2/9/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import "STAddFollowingSetOfAdviceTVC.h"
#import "STSetsOfAdviceTVC.h"
#import "SetOfAdvice.h"

@interface STAddFollowingSetOfAdviceTVC ()
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL isFilteredForFollowingSetsOfAdvice;

@property (strong, nonatomic) NSArray *allSetsOfAdvice;
@property (strong, nonatomic) NSMutableArray *selectedSetsOfAdvice;
@property (strong, nonatomic) NSArray *followingSetsOfAdvice;

@end

@implementation STAddFollowingSetOfAdviceTVC


#pragma mark - View loading and appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
		
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
	NSLog(@"View is appearing.");
	NSLog(@"Number of Sets Of Advice not being followed: %i", [self.notFollowingSetsOfAdvice count]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
	return [self.notFollowingSetsOfAdvice count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SetOfAdvice	*setOfAdvice;
	static NSString *setOfAdviceCellIdentifier	= @"setOfAdviceName";
	UITableViewCell *setOfAdviceCell			= [tableView dequeueReusableCellWithIdentifier:setOfAdviceCellIdentifier];
	
	setOfAdvice									= [self.notFollowingSetsOfAdvice objectAtIndex:indexPath.row];
	setOfAdviceCell.textLabel.text				= setOfAdvice.name;
	
	return setOfAdviceCell;
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	SetOfAdvice *setOfAdvice;
	setOfAdvice		= [self.notFollowingSetsOfAdvice objectAtIndex:indexPath.row];
	
	if ([self.delegate respondsToSelector:@selector(addFollowingSetOfAdviceTVC:didAddSetOfAdvice:)]) {
		[self.delegate addFollowingSetOfAdviceTVC:self didAddSetOfAdvice:setOfAdvice];
	}
	
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Cancel
- (IBAction)cancel:(id)sender {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
