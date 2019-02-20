//
//  MyAccountController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyAccountController : UIViewController

@property IBOutlet UIScrollView* scrollView;
@property IBOutlet UIView* contentView;
@property IBOutlet NSLayoutConstraint* widthConstraint;
@property IBOutlet UILabel* userNameLabel;

@end
