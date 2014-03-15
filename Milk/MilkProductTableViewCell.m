//
//  MilkProductTableViewCell.m
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import "MilkProductTableViewCell.h"

@implementation MilkProductTableViewCell

-(void)updateSize {
    [self.titleField invalidateIntrinsicContentSize];
    [self.detailField invalidateIntrinsicContentSize];
}

@end
