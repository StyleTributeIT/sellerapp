//
//  TopCategoriesViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/3/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "TopCategoriesViewController.h"
#import "GlobalHelper.h"
#import "CategoryCell.h"
#import "ApiRequester.h"
#import <MRProgress.h>
#import "DataCache.h"
#import "CategoryViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface TopCategoriesViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionCategories;

@end

@implementation TopCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    //self.categoriesTableView.accessibilityIdentifier = @"Choose category table";
    self.collectionCategories.accessibilityIdentifier = @"Choose category table";
    self.collectionCategories.delegate = self;
    self.collectionCategories.dataSource = self;
    if([DataCache sharedInstance].categories == nil) {
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] getCategories:^(NSArray *categories) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [DataCache sharedInstance].categories = categories;
            
            [self.collectionCategories reloadData];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
        }];
    }
}



#pragma mark CollectionView delegate



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionCategories deselectItemAtIndexPath:indexPath animated:NO];
    self.selectedCategory = [[DataCache sharedInstance].categories objectAtIndex:indexPath.row];
   // [self performSegueWithIdentifier:@"unwindToAddItem" sender:self];
    [self performSegueWithIdentifier:@"ChooseBrandSegue2" sender:nil];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [DataCache sharedInstance].categories.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryViewCell *cell = (CategoryViewCell*)[_collectionCategories dequeueReusableCellWithReuseIdentifier:@"categoryCell" forIndexPath:indexPath];
    STCategory* category = [[DataCache sharedInstance].categories objectAtIndex:indexPath.row];
    
    cell.tag = indexPath.row;
    cell.categoryName.text = category.name;
    if(category.thumbnail.length > 0) {
        [cell.categoryImage sd_setImageWithURL:[NSURL URLWithString:category.thumbnail] placeholderImage:[UIImage imageNamed:@"stub"]];
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
 
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
