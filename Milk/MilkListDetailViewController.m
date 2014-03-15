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
    self.titleField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, textSize.width, 44)];
    _titleField.text = _list.title;
    _titleField.textColor = [UIColor blackColor];
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
        total += product.value.doubleValue;
    }
    self.totalValueLabel.text = [NSString stringWithFormat:@"%.2f",total];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [_tableView setEditing:editing animated:animated];
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
        
        if (product.name && ![product.name isEqualToString:@""]) {
            cell.titleField.text = product.name;
        }
        
        cell.detailField.text = [NSString stringWithFormat:@"%.2f",product.value.doubleValue];
        
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self updateTotal];
//        [product.managedObjectContext saveToPersistentStoreAndWait];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
        Product *newProduct = [Product createEntity];
        [_list addProductsObject:newProduct];
        [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        
        MilkProductTableViewCell *newCell = (MilkProductTableViewCell *)[tableView cellForRowAtIndexPath:newIndexPath];
        [newCell.detailField becomeFirstResponder];
    } else {
        MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [cell.detailField becomeFirstResponder];
    }
}

#pragma mark - Text Field Delegate

-(void)cancelEditing:(UIBarButtonItem *)barButtonItem {
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
        Product *product = self.products[cell.tag-1];
        
        if (_activeTextField == cell.titleField) {
            _activeTextField.text = product.name;
        } else if (_activeTextField == cell.detailField) {
            _activeTextField.text = [NSString stringWithFormat:@"%.2f",product.value.doubleValue];
        }
        
        [cell updateSize];
        [_activeTextField resignFirstResponder];
    }
}

-(void)applyEditing:(UIBarButtonItem *)barButtonItem {
    if (_activeTextField) {
        [self textFieldShouldEndEditing:_activeTextField];
        [_activeTextField resignFirstResponder];
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.activeTextField = textField;
    
    if (textField != _titleField) {
        MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
        
        if (textField == cell.titleField) {
            cell.detailField.hidden = YES;
        }
        
        [cell updateSize];
    }
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelEditing:)];
    UIBarButtonItem *applyButton = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStyleDone target:self action:@selector(applyEditing:)];
    
    toolbar.barTintColor = [UIColor colorWithRed:57.0/255.0 green:216.0/255.0 blue:193.0/255.0 alpha:1];
    cancelButton.tintColor = [UIColor whiteColor];
    applyButton.tintColor = [UIColor whiteColor];
    
    toolbar.items = [NSArray arrayWithObjects:
                     cancelButton,
                     [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                     applyButton,
                     nil];
    [toolbar sizeToFit];
    textField.inputAccessoryView = toolbar;
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [textField setSelectedTextRange:[textField textRangeFromPosition:textField.beginningOfDocument toPosition:textField.endOfDocument]];
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if (textField == _titleField) {
        _list.title = textField.text;
        
        CGRect frame = _titleField.frame;
        frame.size.width = [_list.title sizeWithAttributes:nil].width;
        _titleField.frame = frame;
        
        return YES;
    }
    
    MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    Product *product = self.products[cell.tag-1];
    
    if (product) {
        if (textField == cell.titleField) {
            product.name = textField.text;
            cell.detailField.hidden = NO;
        } else if (textField == cell.detailField) {
            textField.text = [NSString stringWithFormat:@"%.2f",textField.text.doubleValue];
            [cell updateSize];
            product.value = @(textField.text.doubleValue);
            
            [self updateTotal];
        }
    }
    
//    [product.managedObjectContext saveToPersistentStoreAndWait];
    return YES;
}

-(IBAction)textFieldDidChange:(UITextField *)textField {
    if (textField == _titleField) {
        CGRect frame = _titleField.frame;
        frame.size.width = [_list.title sizeWithAttributes:nil].width;
        _titleField.frame = frame;
        return;
    }
    
    MilkProductTableViewCell *cell = (MilkProductTableViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:textField.tag inSection:0]];
    [cell updateSize];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

@end
