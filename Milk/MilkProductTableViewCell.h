//
//  MilkProductTableViewCell.h
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MilkProductTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextField *titleField;
@property (nonatomic, weak) IBOutlet UITextField *detailField;
@property (nonatomic, weak) IBOutlet UILabel *quantityValueLabel;

-(void)updateSize;

@end
