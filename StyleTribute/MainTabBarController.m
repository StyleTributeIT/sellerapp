//
//  MainTabBarController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 20/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "MainTabBarController.h"
#import "AddWardrobeItemController.h"

@interface MainTabBarController () <UITabBarControllerDelegate>

@property NSUInteger previousTabIndex;

@end

@implementation MainTabBarController

-(id)initWithCoder:(NSCoder *)aDecoder {
    self=  [super initWithCoder:aDecoder];
    if(self) {
        self.previousTabIndex = 0;
        self.delegate = self;
        
        NSDictionary* textAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Gotham-Light" size:11],
                                          NSForegroundColorAttributeName: [UIColor blackColor] };
        NSDictionary* selectedTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Gotham-Light" size:11],
                                          NSForegroundColorAttributeName: [UIColor colorWithRed:1.0 green:0.0 blue:102.0/256 alpha:1] };
        
        UITabBarItem* addItem = [self.tabBar.items objectAtIndex:1];
        [addItem setImage:[[UIImage imageNamed:@"add-item"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        addItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
        
        UITabBarItem* wardrobeItem = [self.tabBar.items objectAtIndex:0];
        [wardrobeItem setImage:[[UIImage imageNamed:@"wardrobe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [wardrobeItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [wardrobeItem setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
        
        UITabBarItem* accountItem = [self.tabBar.items objectAtIndex:2];
        [accountItem setImage:[[UIImage imageNamed:@"account"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [accountItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [accountItem setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
    }
    
    return self;
}

-(void)selectPreviousTab {
    // TODO: Here we can get added item
    //AddWardrobeItemController* controller = [self.selectedViewController.childViewControllers firstObject];
    [self setSelectedIndex:self.previousTabIndex];
}


- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    self.previousTabIndex = self.selectedIndex;
    return YES;
}

@end
