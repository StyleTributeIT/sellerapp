//
//  LoginController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "LoginController.h"
#import "GlobalDefs.h"
#import "GlobalHelper.h"

@implementation LoginController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.forgotPasswordButton setAttributedTitle:[GlobalHelper linkWithString:@"Forgot your password?"] forState:UIControlStateNormal];
    [GlobalHelper configureSlideshow:self.slideShow];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self centerContent];
    [self.slideShow start];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.slideShow stop];
    [super viewWillDisappear:animated];
}

-(IBAction)login:(id)sender {
    
    // for testing
    [self performSegueWithIdentifier:@"mainScreenSegue" sender:self];
    return;
    
//    if([self noEmptyFields]) {
//        if([self validateEmail:self.loginField.text]) {
//            // for testing
//            // TODO: replace by login API method call
//            if([self.passwordField.text isEqualToString:@"123456"]) {
//                [self performSegueWithIdentifier:@"mainScreenSegue" sender:self];
//            } else {
//                [GlobalHelper showMessage:DefInvalidLoginPassword withTitle:@"error"];
//            }
//        } else {
//            [GlobalHelper showMessage:DefInvalidEmail withTitle:@"error"];
//        }
//    } else {
//        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
//    }
}

-(IBAction)forgotPassword:(id)sender {
    NSLog(@"forgotPassword");
}

-(BOOL)noEmptyFields {
    return (self.loginField.text.length > 0 && self.passwordField.text.length > 0);
}

@end
