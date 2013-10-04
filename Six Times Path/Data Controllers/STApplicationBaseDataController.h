//
//  STApplicationBaseData.h
//  Six Times Path
//
//  Created by Doug on 5/9/13.
//  Copyright (c) 2013 A Great Highway. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface STApplicationBaseDataController : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property BOOL debug;

- (BOOL)thereAreCoreDataRecordsForEntity:(NSString *)entityName;
- (void)importDefaultCoreData;




- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
