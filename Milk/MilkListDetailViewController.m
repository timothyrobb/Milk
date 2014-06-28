//
//  MilkListDetailViewController.m
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import "MilkListDetailViewController.h"
#import "MilkProductTableViewCell.h"
#import "List.h"
#import "Product.h"

@interface MilkListDetailViewController ()

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UILabel *totalValueLabel;
@property (nonatomic, weak) UITextField *activeTextField;
@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, assign) BOOL editingText;

@end

@implementation MilkListDetailViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(_list, @"Requires a List object on creation for display purposes");
    
    CGSize textSize = [_list.title sizeWithAttributes:nil];
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, textSize.width * 1.6 + 10, 44)];
    _titleField.text = _list.title;
    _titleField.textColor = [UIColor blackColor];
    _titleField.textAlignment = NSTextAlignmentCenter;
    _titleField.delegate = self;
    [_titleField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.titleView = _titleField;
    
    [self updateTotal];
}

-(NSArray*)products {
    return [_list.products sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdDate" ascending:NO]]];
}

-(void)updateTotal {
    double total = 0.0;
    for (Product *product in _list.products) {
        total += product.totalValue.doubleValue;
    }
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.totalValueLabel.text = [numberFormatter stringFromNumber:@(total)];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_tableView setEditing:editing animated:animated];
}

#pragma mark - Actions

-(void)stepperStepped:(UIStepper *)stepper {
    MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:stepper.tag inSection:0]];
    Product *product = self.products[cell.tag-1];
    
    cell.quantityValueLabel.text = [NSString stringWithFormat:@"x %.0f",stepper.value];
    product.quantity = @(stepper.value);
    [product.managedObjectContext saveToPersistentStoreAndWait];
    [self updateTotal];
}

-(IBAction)selectLabel:(UIButton *)button {
    MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:button.tag inSection:0]];
    [cell.titleField becomeFirstResponder];
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + self.products.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"CreateCell"];
    } else {
        MilkProductTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProductCell"];
        Product *product = self.products[indexPath.row-1];
        
        cell.tag = indexPath.row;
        cell.titleField.tag = indexPath.row;
        cell.detailField.tag = indexPath.row;
        cell.quantityValueLabel.tag = indexPath.row;
        cell.titleFieldButton.tag = indexPath.row;
        
        cell.titleField.text = product.name;
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        cell.detailField.text = [numberFormatter stringFromNumber:product.value];
        
        cell.quantityValueLabel.text = [NSString stringWithFormat:@"x %.0f",product.quantity.doubleValue];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0) {
        MilkProductTableViewCell *milkCell = (MilkProductTableViewCell *)cell;
        [milkCell updateSize];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.row != 0;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Product *product = self.products[indexPath.row-1];
        
        [_list removeProductsObject:product];
        [product deleteEntity];
        [product.managedObjectContext saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                [self updateTotal];
            }
        }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        Product *newProduct = [Product createEntity];
        [_list addProductsObject:newProduct];
        [_list.managedObjectContext saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
            if (success) {
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
                
                MilkProductTableViewCell *newCell = (MilkProductTableViewCell *)[tableView cellForRowAtIndexPath:newIndexPath];
                [newCell.detailField becomeFirstResponder];
            } else {
            	NSLog(@"Error creating new product: %@",error.localizedDescription);
            }
        }];
    } else {
        MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [cell.detailField becomeFirstResponder];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

#pragma mark - Text Field Delegate

-(void)cancelEditing:(UIBarButtonItem *)barButtonItem {
    self.editingText = NO;
    if (_activeTextField) {
        if (_activeTextField == _titleField) {
            _titleField.text = _list.title;
            CGRect frame = _titleField.frame;
            frame.size.width = [_list.title sizeWithAttributes:nil].width;
            _titleField.frame = frame;
            [_titleField resignFirstResponder];
            return;
        }
        
        MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_activeTextField.tag inSection:0]];
        if (cell) {
            Product *product = self.products[cell.tag-1];
            
            if (_activeTextField == cell.titleField) {
                cell.titleField.text = product.name;
            } else if (_activeTextField == cell.detailField) {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                cell.detailField.text = [numberFormatter stringFromNumber:product.value];
            }
            
            [cell updateSize];
        }
        
        [_activeTextField resignFirstResponder];
    }
}

-(void)applyEditing:(UIBarButtonItem *)barButtonItem {
    self.editingText = NO;
    if (_activeTextField) {
        [_activeTextField resignFirstResponder];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.editingText = YES;
    if (textField != _titleField) {
//        MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:];
//        CGPoint point = [cell convertPoint:cell.frame.origin toView:_tableView];
//        [_tableView setContentOffset:CGPointMake(0, cell.frame.origin.y) animated: YES];
        [_tableView setContentInset:UIEdgeInsetsMake(0, 0, 230, 0)];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]
                          atScrollPosition:UITableViewScrollPositionMiddle
                                  animated:YES];
        [_tableView setScrollEnabled:NO];
    }

    self.activeTextField = textField;
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEditing:)];
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(applyEditing:)];
    
    toolbar.barTintColor = [UIColor milkGreen];
    cancelButton.tintColor = [UIColor whiteColor];
    applyButton.tintColor = [UIColor whiteColor];
    
    NSArray *items = @[cancelButton,
                      [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                      applyButton];
    
    if (textField.tag) {
        Product *product = self.products[textField.tag-1];
        
        UIStepper *stepper = [[UIStepper alloc] init];
        stepper.tintColor = [UIColor whiteColor];
        stepper.value = product.quantity.doubleValue;
        stepper.tag = textField.tag;
        [stepper addTarget:self action:@selector(stepperStepped:) forControlEvents:UIControlEventValueChanged];
        UIBarButtonItem *stepperItem = [[UIBarButtonItem alloc] initWithCustomView:stepper];
        
        items = @[cancelButton,
                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                  stepperItem,
                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                  applyButton];
    }
    
    
    toolbar.items = items;
    [toolbar sizeToFit];
    textField.inputAccessoryView = toolbar;
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    self.editingText = YES;
    [textField setSelectedTextRange:[textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument]];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == _titleField) {
        _list.title = textField.text;
        
        CGRect frame = _titleField.frame;
        frame.size.width = [_list.title sizeWithAttributes:nil].width * 1.6 + 10;
        _titleField.frame = frame;
        
        [_list.managedObjectContext saveToPersistentStoreAndWait];
        return YES;
    }
    
    MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    Product *product = nil;
    if (cell) {
        product = self.products[cell.tag-1];
    }
    
    if (product) {
        if (textField == cell.titleField) {
            product.name = textField.text;
        } else if (textField == cell.detailField) {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            
            NSNumber *finalNumber = [numberFormatter numberFromString:textField.text];
            
            if (!finalNumber) {
                finalNumber = @(textField.text.doubleValue);
            }
            product.value = finalNumber;
            textField.text = [numberFormatter stringFromNumber:finalNumber];
            
            [self updateTotal];
        }
        
        [cell updateSize];
        [product.managedObjectContext saveToPersistentStoreAndWait];
    }
    
    return YES;
}

-(IBAction)textFieldDidChange:(UITextField *)textField {
    if (textField == _titleField) {
        CGRect frame = _titleField.frame;
        frame.size.width = [_titleField.text sizeWithAttributes:nil].width * 1.6 + 10;
        _titleField.frame = frame;
        return;
    }
    
    MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    [cell updateSize];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if (!_editingText) {
        [_tableView setContentInset:UIEdgeInsetsZero];
        [_tableView setScrollEnabled:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    self.editingText = NO;
    [textField resignFirstResponder];
    
    return YES;
}

@end
