//
//  MainTabBarController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 20/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarController : UITabBarController

-(void)selectPreviousTab;
// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*)title image:(UIImage*)image;
// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

@end
