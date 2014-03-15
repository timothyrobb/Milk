//
//  Product.m
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import "Product.h"
#import "List.h"


@implementation Product

@dynamic createdDate;
@dynamic name;
@dynamic value;
@dynamic list;

+(id)createEntity {
    List *list = [super createEntity];
    list.createdDate = [NSDate date];
    return list;
}

@end
