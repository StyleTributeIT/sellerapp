//
//  LoginController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController<UITextFieldDelegate>

@property IBOutlet UIScrollView* scrollView;
@property IBOutlet UIView* contentView;
@property IBOutlet NSLayoutConstraint* widthConstraint;

@end
