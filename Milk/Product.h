//
//  Product.h
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class List;

@interface Product : NSManagedObject

@property (nonatomic, retain) NSDate *createdDate;

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *value;

@property (nonatomic, retain) List *list;

@end
