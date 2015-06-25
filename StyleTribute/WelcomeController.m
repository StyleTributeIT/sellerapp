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
#import "GlobalHelper.h"
#import "ApiRequester.h"
#import "DataCache.h"
#import "FBRegistrationController.h"

@interface WelcomeController ()

@property BOOL loadedFirstTime;

@end

@implementation WelcomeController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.loadedFirstTime = YES;
    [GlobalHelper configureSlideshow:self.slideShow];
    [self.signInButton setAttributedTitle:[GlobalHelper linkWithString:@"Sign in"] forState:UIControlStateNormal];
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

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(self.loadedFirstTime) {
        self.loadedFirstTime = NO;
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] getAccountWithSuccess:^(UserProfile *profile) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [DataCache sharedInstance].userProfile = profile;
            
            if([profile isFilled]) {
                [self performSegueWithIdentifier:@"showMainScreenSegue" sender:self];
            } else {
                [self performSegueWithIdentifier:@"moreDetailsSegue" sender:self];
            }
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            NSLog(@"getAccount error: %@", [error description]);
        }];
    }
}

-(IBAction)fbLogin:(id)sender {
//    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
//    NSString* token = [defs stringForKey:@"fbToken"];
//    if(token) {
//        [self performSegueWithIdentifier:@"showMainScreenSegue" sender:self];
//        return;
//    }
    
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
//            [defs setObject:result.token.tokenString forKey:@"fbToken"];
            
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            [[ApiRequester sharedInstance] loginWithFBToken:result.token.tokenString success:^(BOOL loggedIn, UserProfile* fbProfile) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [DataCache sharedInstance].userProfile = fbProfile;
                if(loggedIn) {
                    [self performSegueWithIdentifier:@"showMainScreenSegue" sender:self];
                } else {
                    [self performSegueWithIdentifier:@"FBRegistrationSegue" sender:self];
                }
            } failure:^(NSString *error) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                [GlobalHelper showMessage:error withTitle:@"Login error"];
            }];
        }
    }];
}

-(IBAction)unwindToWelcomeController:(UIStoryboardSegue*)sender {
    NSLog(@"unwindToWelcomeController");
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"moreDetailsSegue"]) {
        FBRegistrationController* controller = segue.destinationViewController;
        controller.updatingProfile = YES;
    }
}

@end
