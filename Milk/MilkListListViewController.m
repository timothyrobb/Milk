//
//  MilkViewController.m
//  Milk
//
//  Created by Timothy Robb on 15/03/2014.
//  Copyright (c) 2014 The Milk Co. All rights reserved.
//

#import "MilkListListViewController.h"
#import "MilkListDetailViewController.h"
#import "List.h"

@interface MilkListListViewController ()

@property (nonatomic, strong) NSArray *lists;

@end

@implementation MilkListListViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
	[self reloadData];
}

-(void)reloadData {
    self.lists = [List findAllSortedBy:@"createdDate" ascending:NO];
}

#pragma mark - Table View Data Source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1 + _lists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"CreateCell"];
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListCell"];
        List *list = _lists[indexPath.row-1];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"dd/MM/yy" options:0 locale:[NSLocale currentLocale]]];
        
        cell.textLabel.text = list.title;
        cell.detailTextLabel.text = [dateFormatter stringFromDate:list.modifiedDate];
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell*)cell {
    MilkListDetailViewController *detailViewController = [segue destinationViewController];
    
    if ([cell.reuseIdentifier isEqualToString:@"CreateCell"]) {
        detailViewController.list = [List createEntity];
    } else {
        detailViewController.list = [List findFirstByAttribute:@"title" withValue:cell.textLabel.text];
    }
}

@end
