//
//  MilkProductTableViewCell.h
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MilkProductTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UITextField *titleField;
@property (nonatomic, strong) IBOutlet UITextField *detailField;

-(void)updateSize;

@end
