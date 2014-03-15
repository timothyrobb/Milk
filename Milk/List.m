//
//  List.m
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import "List.h"


@implementation List

@dynamic createdDate;
@dynamic modifiedDate;
@dynamic title;
@dynamic products;

+(id)createEntity {
    List *list = [super createEntity];
    list.createdDate = [NSDate date];
    return list;
}

-(void)didChangeValueForKey:(NSString *)key {
    if (![key isEqualToString:@"modifiedDate"]) {
        self.modifiedDate = [NSDate date];
    }
}

@end
