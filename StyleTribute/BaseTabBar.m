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
    [super viewDidLoad];

    UIImage* shadowImage = [UIImage imageNamed:@"topShadow"];
    
    CGFloat scale = self.tabBar.frame.size.width / shadowImage.size.width;
    CGFloat newHeight = shadowImage.size.height * scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(self.tabBar.frame.size.width, newHeight));
    [shadowImage drawInRect:CGRectMake(0.0, 0.0, self.tabBar.frame.size.width, newHeight)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    [UITabBar appearance].shadowImage = scaledImage;
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
      //  UIImage* tabBarBackground = [self imageWithImage:[UIImage imageNamed:@"topShadow"] scaledToSize:CGSizeMake(self.view.frame.size.width, self.tabBar.frame.size.height * 1.111f)];
        //[UITabBar appearance].shadowImage = [self imageWithImage:[UIImage imageNamed:@"topShadow"] scaledToSize:self.view.frame.size.width];
        for (UITabBarItem *tbi in self.tabBar.items) {
            tbi.image = [tbi.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
    return self;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UITabBarItem* tabBarItem = self.tabBar.items.firstObject;
    
    CGFloat itemWidth = tabBarItem.image.size.width * 2.0;

    self._button_sell = [UIButton buttonWithType:UIButtonTypeCustom];
    self._button_sell.frame = CGRectMake(0.0, 0.0, itemWidth, itemWidth);
    
    [self._button_sell setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self._button_sell setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self._button_sell setTitle:@"Sell" forState:UIControlStateNormal];

    self._button_sell.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, - (itemWidth + 23), 0.0);

    [self._button_sell setTitleColor:[UIColor colorWithRed:141.f/255 green:141.f/255 blue:141.f/255 alpha:1.f] forState: UIControlStateNormal];
    [self._button_sell.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Regular" size:11]];
    [self._button_sell addTarget:self action:@selector(addItemButtonPressed) forControlEvents:(UIControlEventTouchUpInside)];

    [self.view addSubview:self._button_sell];
}

- (void) adjustPositionSellButton
{
    CGPoint centerTabBar = self.tabBar.center;
    
    CGFloat bottomAnchor = 0.0;
    
    if (@available(iOS 11.0, *))
    {
        bottomAnchor = self.view.safeAreaInsets.bottom * 0.5;
    }
    
    CGFloat buttonX = (self.tabBar.frame.size.width * 0.5) - (self._button_sell.frame.size.width * 0.5);
    CGFloat buttonY = centerTabBar.y - self._button_sell.frame.size.height - bottomAnchor;
    
    self._button_sell.frame = CGRectMake(buttonX, buttonY, self._button_sell.frame.size.width, self._button_sell.frame.size.height);
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
