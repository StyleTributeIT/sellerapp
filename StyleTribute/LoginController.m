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
#import "ApiRequester.h"
#import <MRProgress.h>
#import "DataCache.h"

@interface LoginController () <UIAlertViewDelegate>

@end

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
//    [self performSegueWithIdentifier:@"mainScreenSegue" sender:self];
//    return;
    
    if([self noEmptyFields]) {
        if([self validateEmail:self.loginField.text]) {
            [self.activeField resignFirstResponder];
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            [[ApiRequester sharedInstance] loginWithEmail:self.loginField.text andPassword:self.passwordField.text success:^(UserProfile* profile) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [DataCache sharedInstance].userProfile = profile;
                if(profile.userName.length == 0) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enter your username" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
                    [alert show];
                } else {
                    [self performSegueWithIdentifier:@"mainScreenSegue" sender:self];
                }
            } failure:^(NSString *error) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                
                if([error isEqualToString:@"credentials"]) {
                    [GlobalHelper showMessage:DefInvalidLoginPassword withTitle:@"Login error"];
                } else {
                    [GlobalHelper showMessage:error withTitle:@"Login error"];
                }
            }];
            
        } else {
            [GlobalHelper showMessage:DefInvalidEmail withTitle:@"error"];
        }
    } else {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
    }
}

-(IBAction)forgotPassword:(id)sender {
    NSLog(@"forgotPassword");
}

-(BOOL)noEmptyFields {
    return (self.loginField.text.length > 0 && self.passwordField.text.length > 0);
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UITextField* textField = [alertView textFieldAtIndex:0];
    [DataCache sharedInstance].userProfile.userName = textField.text;
    
    // TODO: here we should call API to update account
    [self performSegueWithIdentifier:@"mainScreenSegue" sender:self];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    UITextField* textField = [alertView textFieldAtIndex:0];
    return textField.text.length > 5;
}

@end
