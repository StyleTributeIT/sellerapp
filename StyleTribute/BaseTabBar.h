//
//  BaseTabBar.h
//  StyleTribute
//
//  Created by Mcuser on 11/24/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTabBar : UITabBarController<UITabBarControllerDelegate, UITabBarDelegate>

@property (nonnull, nonatomic, strong) UIButton* _button_sell;

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

- (void) adjustPositionSellButton;
@end
