//
//  MilkListDetailViewController.h
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@class List;

@interface MilkListDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) List *list;
@property (nonatomic, strong) IBOutlet UIView *emptyView;

@end
