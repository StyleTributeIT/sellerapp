//
//  BaseInputController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseInputController : UIViewController

@property IBOutlet UIScrollView* scrollView;
@property IBOutlet UIView* contentView;
@property IBOutlet NSLayoutConstraint* widthConstraint;

-(BOOL)validateEmail:(NSString *)candidate;
-(void)centerContent;
-(void)moveContentToTop;

@end
