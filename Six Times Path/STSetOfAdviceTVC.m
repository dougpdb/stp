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
#import "UIFont+ST.h"

@interface STSetOfAdviceTVC ()

@property (readonly) CGFloat screenWidth;
@property (readonly) CGFloat guidelineLabelWidth;
@property (readonly) CGFloat setOfAdviceLabelWidth;

@end

@implementation STSetOfAdviceTVC

#pragma mark - getters and setters
-(CGFloat)screenWidth
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	if (
		([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortrait) ||
		([[UIApplication sharedApplication] statusBarOrientation] == UIDeviceOrientationPortraitUpsideDown)
		){
		return screenRect.size.width;
	} else {
		return screenRect.size.height;
	}
}

-(CGFloat)guidelineLabelWidth
{
	return self.screenWidth - 65.0; //15.0 - 25.0 - 15.0 - 10.0;
}

-(CGFloat)setOfAdviceLabelWidth
{
	return self.screenWidth - 30.0; //15.0 - 15.0;
}

#pragma mark - View loading and appearing

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @""; // self.selectedSetOfAdvice.name;

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(preferredContentSizeChanged:)
												 name:UIContentSizeCategoryDidChangeNotification
											   object:nil];
}


- (void)preferredContentSizeChanged:(NSNotification *)aNotification {
    [self.tableView reloadData];
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
}



#pragma mark - Core Data

- (void)setupFetchedResultsController
{
    NSString *entityName = @"Advice";
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    request.predicate = [NSPredicate predicateWithFormat:@"ANY containedWithinSetOfAdvice.name = %@", self.selectedSetOfAdvice.name];
	request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"orderNumberInSet"
															 ascending:YES
															  selector:@selector(localizedCaseInsensitiveCompare:)]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:self.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self performFetch];
}



#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
		
		static NSString *setOfAdviceCellIdentifier = @"setOfAdviceCell";
		UITableViewCell *setOfAdviceCell = [tableView dequeueReusableCellWithIdentifier:setOfAdviceCellIdentifier];
		
		UILabel *nameOfTraditionLabel = (UILabel *)[setOfAdviceCell viewWithTag:10];
		UILabel *nameOfSetOfAdviceLabel = (UILabel *)[setOfAdviceCell viewWithTag:11];

		nameOfTraditionLabel.font = [UIFont preferredFontForTraditionName];
		nameOfSetOfAdviceLabel.font = [UIFont preferredFontForSetOfAdviceName];
		
		nameOfTraditionLabel.text = self.selectedSetOfAdvice.practicedWithinTradition.name;
		nameOfSetOfAdviceLabel.text = self.selectedSetOfAdvice.name;
		
		[self resizeHeightToFitForLabel:nameOfSetOfAdviceLabel
							 labelWidth:self.setOfAdviceLabelWidth];

		return setOfAdviceCell;
		
	} else {
		
		static NSString *adviceCellIdentifier = @"adviceInASetCell";
		UITableViewCell *adviceCell = [tableView dequeueReusableCellWithIdentifier:adviceCellIdentifier];
		
		UILabel *orderNumberOfAdviceInSetLabel = (UILabel *)[adviceCell viewWithTag:10];
		UILabel *nameOfAdviceLabel = (UILabel *)[adviceCell viewWithTag:11];
		
		Advice *advice = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row-1];

		nameOfAdviceLabel.font = [UIFont preferredFontForAdviceNameInSetOfAdviceListing];
		
		orderNumberOfAdviceInSetLabel.text = [advice.orderNumberInSet stringValue];
		nameOfAdviceLabel.text = advice.name;
		
		[self resizeHeightToFitForLabel:nameOfAdviceLabel
							 labelWidth:self.guidelineLabelWidth];

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
	if (indexPath.row == 0) {
		
		
		UILabel *traditionNameLabel = [UILabel new];
		UILabel *setOfAdviceNameLabel = [UILabel new];
		
		setOfAdviceNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
		
		traditionNameLabel.font = [UIFont preferredFontForTraditionName];
		setOfAdviceNameLabel.font = [UIFont preferredFontForSetOfAdviceName];
		
		traditionNameLabel.text = @"placeholder name";
		setOfAdviceNameLabel.text = self.selectedSetOfAdvice.practicedWithinTradition.name;
				
		CGFloat traditionNameLabelHeight = [self heightForLabel:traditionNameLabel
													   withText:traditionNameLabel.text
													 labelWidth:self.setOfAdviceLabelWidth];
		
		CGFloat setOfAdviceNameLabelHeight = [self heightForLabel:setOfAdviceNameLabel
												  withText:setOfAdviceNameLabel.text
												labelWidth:self.setOfAdviceLabelWidth];
		
		return traditionNameLabelHeight + setOfAdviceNameLabelHeight + setOfAdviceNameLabel.font.pointSize * 1.2;
		
	} else {
		
		UILabel *adviceNameLabel = [UILabel new];
		adviceNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
		adviceNameLabel.font = [UIFont preferredFontForAdviceNameInSetOfAdviceListing];
		
		Advice *advice = [[self.fetchedResultsController fetchedObjects] objectAtIndex:indexPath.row-1];
		adviceNameLabel.text = advice.name;
		
		CGFloat adviceNameLabelHeight = [self heightForLabel:adviceNameLabel
											  withText:adviceNameLabel.text
											labelWidth:self.guidelineLabelWidth];
		
		return adviceNameLabelHeight + adviceNameLabel.font.pointSize * 1.2;

	}
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 0.1f;
}


#pragma mark - Managing Cell and Label Heights

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

	return height;
}

-(void)resizeHeightToFitForLabel:(UILabel *)label labelWidth:(CGFloat)labelWidth
{
	CGRect newFrame = label.frame;
	newFrame.size.height = [self heightForLabel:label
									   withText:label.text
									 labelWidth:labelWidth];
	label.frame = newFrame;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

@end
