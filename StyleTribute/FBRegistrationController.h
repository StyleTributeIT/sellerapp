//
//  FBRegistrationController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 29/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"

@interface FBRegistrationController : BaseInputController

@property IBOutlet UITextField* userNameField;
@property IBOutlet UITextField* firstNameField;
@property IBOutlet UITextField* lastNameField;
@property IBOutlet UITextField* countryField;
@property IBOutlet UITextField* phoneField;

-(IBAction)createAccount:(id)sender;

@end
