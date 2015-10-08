//
//  EditProfileController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"

@interface EditProfileController : BaseInputController

@property IBOutlet UITextField* emailField;
@property IBOutlet UITextField* firstNameField;
@property IBOutlet UITextField* lastNameField;
@property IBOutlet UITextField* countryField;

@end
