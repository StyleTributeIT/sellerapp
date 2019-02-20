//
//  ChooseCategoryController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 05/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ChooseCategoryController.h"
#import "CategoryCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ChooseCategoryController ()

@end

@implementation ChooseCategoryController

-(void)viewDidLoad {
    [super viewDidLoad];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    self.categoriesTableView.accessibilityIdentifier = @"Choose category table";
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    if([DataCache sharedInstance].categories == nil) {
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] getCategories:^(NSArray *categories) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            
            [DataCache sharedInstance].categories = categories;
            
            [self.categoriesTableView reloadData];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [DataCache sharedInstance].categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CategoryCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    STCategory* category = [[DataCache sharedInstance].categories objectAtIndex:indexPath.row];
    
    cell.tag = indexPath.row;
    cell.categoryName.text = category.name;
    if(category.thumbnail.length > 0) {
        [cell.categoryImage sd_setImageWithURL:[NSURL URLWithString:category.thumbnail] placeholderImage:[UIImage imageNamed:@"stub"]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedCategory = [[DataCache sharedInstance].categories objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"unwindToAddItem" sender:self];
}

@end
