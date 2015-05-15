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

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
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
