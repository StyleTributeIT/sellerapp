//
//  FBRegistrationController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 29/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "FBRegistrationController.h"

@implementation FBRegistrationController

-(IBAction)createAccount:(id)sender {
    if([self noEmptyFields]) {
        //
    } else {
        [[[UIAlertView alloc] initWithTitle:@"error"  message:@"Please fill in all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

-(BOOL)noEmptyFields {
    return (self.userNameField.text.length > 0 &&
            self.firstNameField.text.length > 0 &&
            self.lastNameField.text.length > 0 &&
            self.countryField.text.length > 0 &&
            self.phoneField.text.length > 0);
}

@end
