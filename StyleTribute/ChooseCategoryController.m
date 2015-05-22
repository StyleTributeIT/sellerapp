//
//  ChooseCategoryController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 05/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "ChooseCategoryController.h"
#import "CategoryCell.h"

@interface ChooseCategoryController ()

@property NSArray* categories;

@end

@implementation ChooseCategoryController

-(void)viewDidLoad {
    [super viewDidLoad];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    self.categories = @[@"BAGS", @"SHOES", @"CLOTHING", @"ACCESSORIES"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.tag = indexPath.row;
    cell.categoryName.text = [self.categories objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedCategory = [self.categories objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"unwindToAddItem" sender:self];
}

@end
