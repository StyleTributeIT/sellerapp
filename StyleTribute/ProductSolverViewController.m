//
//  ProductSolverViewController.m
//  StyleTribute
//
//  Created by Mcuser on 12/22/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ProductSolverViewController.h"
#import "NewItemTableViewController.h"
#import "DataCache.h"
#import "Product.h"

@interface ProductSolverViewController ()

@end

@implementation ProductSolverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIStoryboard *storyboard =
    [UIStoryboard storyboardWithName:@"ProductFlow" bundle:nil];
    if ([DataCache getSelectedItem].identifier != 0)
    {
        NewItemTableViewController *viewController =
        [storyboard instantiateViewControllerWithIdentifier:@"AddWardrobeItemController"];
        [self.view insertSubview:viewController.view atIndex:0];
        
    } else {
        
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
