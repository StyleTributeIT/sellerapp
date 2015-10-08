//
//  FBRegistrationController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 29/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"
#import <KASlideShow.h>

@interface FBRegistrationController : BaseInputController

@property IBOutlet UITextField* firstNameField;
@property IBOutlet UITextField* lastNameField;
@property IBOutlet UITextField* countryField;
@property IBOutlet UITextField* phoneField;
@property IBOutlet KASlideShow* slideShow;
@property IBOutlet UIButton* accountButton;

@property BOOL updatingProfile;

-(IBAction)createAccount:(id)sender;

@end
