//
//  RegistrationController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "RegistrationController.h"

@implementation RegistrationController

-(IBAction)createAccount:(id)sender {
    if([self noEmptyFields]) {
        if([self validateEmail:self.emailField.text]) {
            // login
        } else {
            [[[UIAlertView alloc] initWithTitle:@"error"  message:@"Invalid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"error"  message:@"Please fill in all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

-(BOOL)noEmptyFields {
    return (self.userNameField.text.length > 0 &&
            self.passwordField.text.length > 0 &&
            self.firstNameField.text.length > 0 &&
            self.lastNameField.text.length > 0 &&
            self.emailField.text.length > 0 &&
            self.countryField.text.length > 0 &&
            self.phoneField.text.length > 0);
}

@end
