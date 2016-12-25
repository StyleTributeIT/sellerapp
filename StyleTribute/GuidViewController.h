//
//  GuidViewController.h
//  StyleTribute
//
//  Created by Maxim Vasilkov on 17/11/2016.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuidViewControllerDelegate

-(void)showCamera;

@end

@interface GuidViewController : UIViewController<UIPageViewControllerDataSource>
@property (strong, nonatomic) UIPageViewController *pageController;
@property id<GuidViewControllerDelegate> delegate;
@property BOOL hideSkipButton;
@end
