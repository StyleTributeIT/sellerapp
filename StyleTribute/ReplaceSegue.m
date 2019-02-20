//
//  ReplaceSegue.m
//  StyleTribute
//
//  Created by Mcuser on 11/19/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ReplaceSegue.h"
#import "ChooseBrandController.h"
#import "TopCategoriesViewController.h"
#import "ProductNavigationViewController.h"

@implementation ReplaceSegue
- (void)perform {
    
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    UINavigationController *navigationController = sourceViewController.navigationController;
    
    NSMutableArray *controllerStack = [NSMutableArray arrayWithArray:navigationController.viewControllers];
    
    for (int i = 0; i < controllerStack.count; i++) {
        UIViewController *vc = [controllerStack objectAtIndex:i];
        if ([vc isKindOfClass:[ProductNavigationViewController class]])
        {
            navigationController = (ProductNavigationViewController*)vc;
            [controllerStack removeObject:vc];
        }
        if ([vc isKindOfClass:[destinationController class]])
            [controllerStack removeObject:vc];
    }
    [controllerStack addObject:destinationController];
    [sourceViewController.navigationController setViewControllers:controllerStack animated:YES];
}
@end
