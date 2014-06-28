//
//  Product.m
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import "Product.h"
#import "List.h"

@interface Product ()

@property (nonatomic, retain) NSNumber *userTotalValue;

@end

@implementation Product

@dynamic createdDate;
@dynamic name;

@dynamic value;
@dynamic quantity;
@dynamic totalValue;
@dynamic userTotalValue;

@dynamic list;

+(id)createEntity {
    List *list = [super createEntity];
    list.createdDate = [NSDate date];
    return list;
}

-(NSNumber *)totalValue {
    if (self.userTotalValue) {
        return self.userTotalValue;
    } else {
        return @(self.value.doubleValue * self.quantity.doubleValue);
    }
}

-(void)setTotalValue:(NSNumber *)totalValue {
    [self setUserTotalValue:totalValue];
}

@end
