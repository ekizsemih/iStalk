//
//  DataEntity.h
//  iStalk
//
//  Created by Semih EKIZ on 28/12/15.
//  Copyright © 2015 Semih EKIZ. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface DataEntity : NSManagedObject
@property (nullable, nonatomic, strong) NSNumber *userId;
@property (nullable, nonatomic, retain) NSNumber *iD;
@property (nullable, nonatomic, retain) NSString *nameSurname;
@property (nullable, nonatomic, retain) NSData *fbObject;
@property (nullable, nonatomic, retain) NSData *twObject;
@property (nullable, nonatomic, retain) NSData *fsObject;
@property (nullable, nonatomic, retain) NSData *insObject;
@end
