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
#import "SpiritualTradtion.h"
#import "UIFont+ST.h"

#define SET_OF_ADVICE_LABEL_WIDTH	272
#define GUIDELINE_LABEL_WIDTH		272


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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SetOfAdvice	*setOfAdvice;
	UILabel *traditionNameLabel = [UILabel new];
	traditionNameLabel.font = [UIFont preferredFontForTraditionName];
	traditionNameLabel.text = @"placeholder name";
	
	UILabel *setOfAdviceLabel		= [UILabel new];
	setOfAdviceLabel.lineBreakMode	= NSLineBreakByWordWrapping;
	setOfAdviceLabel.font			= [UIFont preferredFontForSetOfAdviceName];
	
	setOfAdvice = [self.notFollowingSetsOfAdvice objectAtIndex:indexPath.row];
		
	setOfAdviceLabel.text = setOfAdvice.name;
	
	CGFloat traditionLabelHeight = [self heightForLabel:traditionNameLabel
											   withText:traditionNameLabel.text
											 labelWidth:SET_OF_ADVICE_LABEL_WIDTH];
	
	CGFloat setOfAdviceLabelHeight = [self heightForLabel:setOfAdviceLabel
												 withText:setOfAdviceLabel.text
											   labelWidth:SET_OF_ADVICE_LABEL_WIDTH];
	
	return traditionLabelHeight + 4 + setOfAdviceLabelHeight + setOfAdviceLabel.font.pointSize * 1.2;		// change for landscape orientation?
}

#pragma mark Managing Cell and Label Heights
-(CGFloat)heightForLabel:(UILabel *)label withText:(NSString *)text labelWidth:(CGFloat)labelWidth
{
	UIFont *font	= label.font;
	NSAttributedString *attributedText = [ [NSAttributedString alloc]
										  initWithString:text
										  attributes: @{NSFontAttributeName: font}
										  ];
	CGRect rect		= [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX}
												options:NSStringDrawingUsesLineFragmentOrigin
												context:nil];
	CGSize size		= rect.size;
	CGFloat height	= ceilf(size.height);
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

	SetOfAdvice	*setOfAdvice;
	static NSString *setOfAdviceCellIdentifier	= @"setOfAdviceCell";
	UITableViewCell *setOfAdviceCell			= [tableView dequeueReusableCellWithIdentifier:setOfAdviceCellIdentifier];
	
	UILabel *nameOfTraditionLabel				= (UILabel *)[setOfAdviceCell viewWithTag:10];
	UILabel *nameOfSetOfAdviceLabel				= (UILabel *)[setOfAdviceCell viewWithTag:11];
		
	setOfAdvice									= [self.notFollowingSetsOfAdvice objectAtIndex:indexPath.row];
		
	nameOfTraditionLabel.font = [UIFont preferredFontForTraditionName];
	nameOfSetOfAdviceLabel.font = [UIFont preferredFontForSetOfAdviceName];
	
	nameOfTraditionLabel.text					= setOfAdvice.practicedWithinTradition.name;
	nameOfSetOfAdviceLabel.text					= setOfAdvice.name;
	
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
