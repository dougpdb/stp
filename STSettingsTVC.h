//
//  STSettingsViewController.h
//  Six Times Path
//
//  Created by Doug on 11/9/12.
//  Copyright (c) 2012 6000 American Family Dr. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface STSettingsTVC : UITableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@end
