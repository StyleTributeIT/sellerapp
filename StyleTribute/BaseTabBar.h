//
//  BaseTabBar.h
//  StyleTribute
//
//  Created by Mcuser on 11/24/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTabBar : UITabBarController
// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*)title image:(UIImage*)image;

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;
@end
