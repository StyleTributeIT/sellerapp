//
//  BaseTabBar.m
//  StyleTribute
//
//  Created by Mcuser on 11/24/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "BaseTabBar.h"

@interface BaseTabBar ()

@end

@implementation BaseTabBar

NSInteger CENTER_BTN_IDX = 3;

-(void)viewDidLoad
{
    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIImage* tabBarBackground = [self imageWithImage:[UIImage imageNamed:@"topShadow"] scaledToSize:CGSizeMake(self.view.frame.size.width, 50)];
        [UITabBar appearance].shadowImage = tabBarBackground;
        for (UITabBarItem *tbi in self.tabBar.items) {
            tbi.image = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        
    }
    return self;
}


- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    
}

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
    UIViewController* viewController = [[UIViewController alloc] init];
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    viewController.tabBarItem.imageInsets = UIEdgeInsetsMake(45, 0, -45, 0);
    return viewController;
}

- (void)viewWillLayoutSubviews {
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 95;
    tabFrame.origin.y = self.view.frame.size.height - 55;
    self.tabBar.frame = tabFrame;
    
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width + 5, buttonImage.size.height + 5);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button setTitle:@"Sell" forState:UIControlStateNormal];
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (button.frame.size.height + 27), 0.0);
    [button setTitleColor:[UIColor colorWithRed:141.f/255 green:141.f/255 blue:141.f/255 alpha:1.f] forState: UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Light" size:11]];
    [button addTarget:self action:@selector(addItemButtonPressed) forControlEvents:(UIControlEventTouchUpInside)];
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - 32;
        button.center = center;
    }
    [self.view addSubview:button];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    if (viewController.view.tag == CENTER_BTN_IDX)
    {
        
    }
}

-(void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (selectedIndex == CENTER_BTN_IDX)
        [self addItemButtonPressed];
    else
        [super setSelectedIndex:selectedIndex];
}

- (void) addItemButtonPressed{
    [DataCache setSelectedItem:nil];
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemNavController"] animated:YES completion:nil] ;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end
