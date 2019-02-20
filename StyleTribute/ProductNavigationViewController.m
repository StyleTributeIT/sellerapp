//
//  ProductNavigationViewController.m
//  StyleTribute
//
//  Created by Mcuser on 12/22/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ProductNavigationViewController.h"
#import "NewItemTableViewController.h"
#import "TopCategoriesViewController.h"
#import "DataCache.h"
#import "Product.h"

@interface ProductNavigationViewController ()

@end

@implementation ProductNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:@"ProductFlow" bundle:nil];
    if ([DataCache getSelectedItem].identifier != 0)
    {
        NewItemTableViewController *viewController =
        [storyboard instantiateViewControllerWithIdentifier:@"AddWardrobeItemController"];
        viewController.isEditingItem = YES;
        //[self.view insertSubview:viewController.view atIndex:0];
        [self.navigationController pushViewController:viewController animated:NO];
    } else {
        self.curProduct = [Product new];
        [DataCache setSelectedItem:self.curProduct];
        [DataCache sharedInstance].isEditingItem = NO;
        TopCategoriesViewController *viewController =
        [storyboard instantiateViewControllerWithIdentifier:@"categorySelection"];
        //[self.view insertSubview:viewController.view atIndex:0];
        [self.navigationController pushViewController:viewController animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
