//
//  ResidentAddressController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"

@interface ResidentAddressController : BaseInputController<UIPickerViewDataSource, UIPickerViewDelegate>

@property IBOutlet UITextField* companyField;
@property IBOutlet UITextField* firstNameField;
@property IBOutlet UITextField* lastNameField;
@property IBOutlet UITextField* cityField;
@property IBOutlet UITextField* countryField;
@property IBOutlet UITextField* postalCodeField;
@property IBOutlet UITextField* phoneNumberField;
@property IBOutlet UITextField* addressField;
@property IBOutlet UITextField* stateField;

@end
