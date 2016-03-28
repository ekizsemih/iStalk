//
//  DataEntity+CoreDataProperties.h
//  iStalk
//
//  Created by Semih EKIZ on 28/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "DataEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface DataEntity (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *userId;
@property (nullable, nonatomic, retain) NSData *fbObject;
@property (nullable, nonatomic, retain) NSData *twObject;
@property (nullable, nonatomic, retain) NSData *fsObject;
@property (nullable, nonatomic, retain) NSData *insObject;

@end

NS_ASSUME_NONNULL_END
