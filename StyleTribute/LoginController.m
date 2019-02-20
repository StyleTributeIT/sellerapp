//
//  LoginController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "LoginController.h"
#import "FBRegistrationController.h"

@interface LoginController () <UIAlertViewDelegate>

@end

@implementation LoginController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.forgotPasswordButton setAttributedTitle:[GlobalHelper linkWithString:@"Forgot your password?"] forState:UIControlStateNormal];
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

    if([self noEmptyFields]) {
        if([self validateEmail:self.loginField.text]) {
            [self.activeField resignFirstResponder];
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            [[ApiRequester sharedInstance] loginWithEmail:self.loginField.text andPassword:self.passwordField.text success:^(UserProfile* profile) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [[ApiRequester sharedInstance] getAccountWithSuccess:^(UserProfile *profile){
                    //[DataCache sharedInstance].userProfile = profile;
                    
                    if([profile isFilled]) {
                        [self performSegueWithIdentifier:@"mainScreenSegue" sender:self];
                    } else {
                        [self performSegueWithIdentifier:@"moreDetailsSegue" sender:self];
                    }
                }
                failure:^(NSString *error)
                {
                    
                }];
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
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://m.styletribute.com/recoverpassword"]];
}

-(BOOL)noEmptyFields {
    return (self.loginField.text.length > 0 && self.passwordField.text.length > 0);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"moreDetailsSegue"]) {
        FBRegistrationController* controller = segue.destinationViewController;
        controller.updatingProfile = YES;
    }
}

@end
