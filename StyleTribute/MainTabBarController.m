//
//  MainTabBarController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 20/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "MainTabBarController.h"
#import "AddWardrobeItemController.h"
#import <CoreGraphics/CoreGraphics.h>

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
        addItem.imageInsets = UIEdgeInsetsMake(-20, 0, 20, 0);
        addItem.accessibilityLabel = @"Add item";
        [addItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [addItem setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
        [addItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        
        UITabBarItem* wardrobeItem = [self.tabBar.items objectAtIndex:0];
        [wardrobeItem setImage:[[UIImage imageNamed:@"wardrobe"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        wardrobeItem.imageInsets = UIEdgeInsetsMake(-8, 0, 8, 0);
        [wardrobeItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [wardrobeItem setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
        [wardrobeItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        
        UITabBarItem* accountItem = [self.tabBar.items objectAtIndex:2];
        [accountItem setImage:[[UIImage imageNamed:@"account"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        accountItem.imageInsets = UIEdgeInsetsMake(-8, 0, 8, 0);
        [accountItem setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
        [accountItem setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
        [accountItem setTitlePositionAdjustment:UIOffsetMake(0, -4)];
        
        [self.tabBar setBackgroundImage:[self resizeBackgroundImage:[UIImage imageNamed:@"TabBar"]]];
        self.tabBar.barTintColor = [UIColor clearColor];
        self.tabBar.selectedImageTintColor = [UIColor clearColor];
//        self.tabBar.selectionIndicatorImage = [UIImage new];
        self.tabBar.shadowImage = [UIImage new];
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

-(UIImage*)resizeBackgroundImage:(UIImage*)image {
    CGSize xsize = CGSizeMake(self.view.frame.size.width, image.size.height);
    CGFloat edgeWidth = round((xsize.width - image.size.width)/2);
    
    CGImageRef edgeImage = CGImageCreateWithImageInRect(image.CGImage, CGRectMake(0, 0, edgeWidth*2, image.size.height*2));
    
    UIGraphicsBeginImageContext(xsize);
    UIImage* img = [UIImage imageWithCGImage:edgeImage];
    [image drawInRect:CGRectMake(edgeWidth, 0, image.size.width, image.size.height)];
    [img drawInRect:CGRectMake(0, 0, edgeWidth, image.size.height)];
    [img drawInRect:CGRectMake(image.size.width + edgeWidth, 0, edgeWidth, image.size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(edgeImage);
    
    return newImage;
}

@end
