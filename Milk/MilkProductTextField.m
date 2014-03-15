//
//  MilkProductTextField.m
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import "MilkProductTextField.h"

@implementation MilkProductTextField

-(CGSize)intrinsicContentSize {
    if (self.hidden) {
        return CGSizeZero;
    }
    CGSize textSize = [self.text sizeWithAttributes:self.defaultTextAttributes];
    if (!self.text || [self.text isEqualToString:@""]) {
        textSize = [self.placeholder sizeWithAttributes:self.defaultTextAttributes];
    }
    return CGSizeMake(ceil(textSize.width), ceil(textSize.height));
}

@end
