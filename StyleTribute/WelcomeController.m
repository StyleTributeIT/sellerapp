//
//  WelcomeController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "WelcomeController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <MRProgress.h>

@implementation WelcomeController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self.slideShow setDelay:6];
    [self.slideShow setTransitionDuration:1];
    [self.slideShow setTransitionType:KASlideShowTransitionSlide];
    [self.slideShow setImagesContentMode:UIViewContentModeScaleAspectFill];
    [self.slideShow addImage:[UIImage imageNamed:@"1.jpg"]];
    [self.slideShow addImage:[UIImage imageNamed:@"2.jpg"]];
    [self.slideShow addImage:[UIImage imageNamed:@"3.jpg"]];
    [self.slideShow addImage:[UIImage imageNamed:@"4.jpg"]];
    [self.slideShow addImage:[UIImage imageNamed:@"5.jpg"]];
    [self.slideShow addImage:[UIImage imageNamed:@"6.jpg"]];
    [self.slideShow addImage:[UIImage imageNamed:@"7.jpg"]];
    [self.slideShow addImage:[UIImage imageNamed:@"8.jpg"]];
    
    // http://stackoverflow.com/questions/25925914/attributed-string-with-custom-fonts-in-storyboard-does-not-load-correctly
    NSAttributedString* signInString = [[NSAttributedString alloc] initWithString:@"Sign in" attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Gotham-Light" size:16], NSForegroundColorAttributeName: [UIColor colorWithRed:1.0 green:0.0 blue:102.0/256 alpha:1], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
    [self.signInButton setAttributedTitle:signInString forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.slideShow start];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.slideShow stop];
}

-(IBAction)fbLogin:(id)sender {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSString* token = [defs stringForKey:@"fbToken"];
    if(token) {
        // We are already logged in
        [self performSegueWithIdentifier:@"showMainScreenSegue" sender:self];
        return;
    }
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    login.loginBehavior = FBSDKLoginBehaviorSystemAccount;
    [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    [login logInWithReadPermissions:@[@"email"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        if (error) {
            NSLog(@"FB login error: %@", [error description]);
        } else if (result.isCancelled) {
            NSLog(@"FB login cancelled");
        } else {
            NSLog(@"FB login succedeed with token: %@", result.token.tokenString);
            [defs setObject:result.token.tokenString forKey:@"fbToken"];
            
            // TODO: call FB registration API method and if it succedeed, go to the next screen
            // to provide more data
            [self performSegueWithIdentifier:@"FBRegistrationSegue" sender:self];
        }
    }];
}

-(IBAction)unwindToWelcomeController:(UIStoryboardSegue*)sender {
    NSLog(@"unwindToWelcomeController");
}

@end
