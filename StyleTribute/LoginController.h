//
//  LoginController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"
#import <UIKit/UIKit.h>
#import <KASlideShow.h>

@interface LoginController : BaseInputController

@property IBOutlet UITextField* loginField;
@property IBOutlet UITextField* passwordField;
@property IBOutlet UIButton* forgotPasswordButton;
@property IBOutlet KASlideShow* slideShow;

-(IBAction)login:(id)sender;
-(IBAction)forgotPassword:(id)sender;

@end
