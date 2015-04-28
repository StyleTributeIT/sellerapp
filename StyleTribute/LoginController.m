//
//  LoginController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "LoginController.h"

@implementation LoginController

-(IBAction)login:(id)sender {
    if([self noEmptyFields]) {
        if([self validateEmail:self.loginField.text]) {
            // login
        } else {
            [[[UIAlertView alloc] initWithTitle:@"error"  message:@"Invalid email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        }
    } else {
        [[[UIAlertView alloc] initWithTitle:@"error"  message:@"Please fill in all fields" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

-(IBAction)forgotPassword:(id)sender {
    NSLog(@"forgotPassword");
}

-(BOOL)noEmptyFields {
    return (self.loginField.text.length > 0 && self.passwordField.text.length > 0);
}

@end
