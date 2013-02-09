//
//  SetOfAdvice.m
//  Six Times Path
//
//  Created by ICE - Doug on 7/17/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "STSetOfAdviceTVC.h"
#import "SetOfAdvice.h"
#import "Advice.h"


@interface STSetOfAdviceTVC ()

@end

@implementation STSetOfAdviceTVC


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupFetchedResultsController];
}



#pragma mark - UI Interactions

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"viewGuidelineDetails"]) {        
//        STSetOfAdviceDetailTVC *setOfAdviceDetailTVC    = segue.destinationViewController;
//        setOfAdviceDetailTVC.managedObjectContext       = self.managedObjectContext;
//        NSLog(@"The name of the selectedSetOfAdvice is %@", self.selectedSetOfAdvice.name);
//        setOfAdviceDetailTVC.selectedSetOfAdvice        = self.selectedSetOfAdvice;
//    } else {
//        NSLog(@"Unidentified segue attempted!");
//    }
}



#pragma mark - Core Data

- (void)setupFetchedResultsController
{
    NSString *entityName			= @"Advice";
    NSFetchRequest *request			= [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate				= [NSPredicate predicateWithFormat:@"ANY containedWithinSetOfAdvice.name = %@", self.selectedSetOfAdvice.name];
	request.sortDescriptors			= @[[NSSortDescriptor sortDescriptorWithKey:@"orderNumberInSet"
                                                                                     ascending:YES
                                                                                      selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController	= [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self performFetch];
}



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
		static NSString *setOfAdviceCellIdentifier	= @"setOfAdviceCell";
		UITableViewCell *setOfAdviceCell			= [tableView dequeueReusableCellWithIdentifier:setOfAdviceCellIdentifier];
		
		UILabel *nameOfTraditionLabel				= (UILabel *)[setOfAdviceCell viewWithTag:10];
		UILabel *nameOfSetOfAdviceLabel				= (UILabel *)[setOfAdviceCell viewWithTag:11];

		nameOfTraditionLabel.text					= self.selectedSetOfAdvice.practicedWithinTradition.name;
		nameOfSetOfAdviceLabel.text					= self.selectedSetOfAdvice.name;
		
		return setOfAdviceCell;
	} else {
		static NSString *adviceCellIdentifier		= @"adviceInASetCell";
		UITableViewCell *adviceCell					= [tableView dequeueReusableCellWithIdentifier:adviceCellIdentifier];
		
		UILabel *orderNumberOfAdviceInSetLabel		= (UILabel *)[adviceCell viewWithTag:10];
		UILabel *nameOfAdviceLabel					= (UILabel *)[adviceCell viewWithTag:11];
		
		Advice *advice								= [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row-1];

		orderNumberOfAdviceInSetLabel.text			= [advice.orderNumberInSet stringValue];
		nameOfAdviceLabel.text						= advice.name;
		
		return adviceCell;
	}
}

#pragma mark - Table View Structure

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self.fetchedResultsController fetchedObjects] count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 85;
}

#pragma mark - Managing Cell and Label Heights
-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text labelWidth:(CGFloat)labelWidth
{
	CGSize maximumLabelSize		= CGSizeMake(labelWidth, FLT_MAX);
	
	CGSize expectedLabelSize	= [text sizeWithFont:label.font
								constrainedToSize:maximumLabelSize
									lineBreakMode:label.lineBreakMode];
	
	return expectedLabelSize.height;
}

-(void)resizeHeightToFitForLabel:(UILabel *)label labelWidth:(CGFloat)labelWidth
{
	CGRect newFrame			= label.frame;
	newFrame.size.height	= [self heightForLabel:label withText:label.text labelWidth:labelWidth];
	label.frame				= newFrame;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
