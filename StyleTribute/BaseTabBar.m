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

-(void)viewDidLoad
{
    
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UIImage* tabBarBackground = [self resizeBackgroundImage:[UIImage imageNamed:@"TabBar"]];
        [[UITabBar appearance] setBackgroundImage:tabBarBackground];
        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
        [UITabBarItem appearance].titlePositionAdjustment = UIOffsetMake(0, -15);
        UIView *toplineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                       1.0f,
                                                                       self.view.frame.size.width, 1.f)];
        toplineView.backgroundColor = [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1.0f];
        [self.view addSubview:toplineView];
        
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

-(UIImage*)resizeBackgroundImage:(UIImage*)image {
    CGSize xsize = CGSizeMake(self.view.frame.size.width, image.size.height + 10.f);
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

// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
    UIViewController* viewController = [[UIViewController alloc] init];
    viewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:image tag:0];
    viewController.tabBarItem.imageInsets = UIEdgeInsetsMake(15, 0, -15, 0);
    return viewController;
}

- (void)viewWillLayoutSubviews {
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 80;
    tabFrame.origin.y = self.view.frame.size.height - 80;
    self.tabBar.frame = tabFrame;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button setTitle:@"Sell" forState:UIControlStateNormal];
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(
                                              0.0, - imageSize.width, - (button.frame.size.height + 20), 0.0);
    [button setTitleColor:[UIColor colorWithRed:141.f/255 green:141.f/255 blue:141.f/255 alpha:1.f] forState: UIControlStateNormal];
    [button.titleLabel setFont:[UIFont fontWithName:@"Montserrat-Light" size:12]];
    [button addTarget:self action:@selector(addItemButtonPressed) forControlEvents:(UIControlEventTouchUpInside)];
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - 30;
        button.center = center;
    }
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - 30;
        button.center = center;
    }
    
    [self.view addSubview:button];
}

- (void) addItemButtonPressed{
    [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AddItemNavController"] animated:YES completion:nil] ;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
@end
