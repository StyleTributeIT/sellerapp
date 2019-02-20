//
//  BankDetailsController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"

@interface BankDetailsController : BaseInputController

@property IBOutlet UITextField* bankNameField;
@property IBOutlet UITextField* accountNumberField;
@property IBOutlet UITextField* swiftCodeField;
@property IBOutlet UITextField* branchCodeField;
@property IBOutlet UITextField* holderNameField;

@end
