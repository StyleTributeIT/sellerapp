//
//  RegistrationController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"
#import <UIKit/UIKit.h>
#import <KASlideShow.h>

@interface RegistrationController : BaseInputController

@property IBOutlet UITextField* passwordField;
@property IBOutlet UITextField* firstNameField;
@property IBOutlet UITextField* lastNameField;
@property IBOutlet UITextField* emailField;
@property IBOutlet UITextField* countryField;
@property IBOutlet UITextField* phoneField;
@property IBOutlet KASlideShow* slideShow;

-(IBAction)createAccount:(id)sender;

@end
