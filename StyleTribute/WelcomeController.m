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
#import "FBRegistrationController.h"

@interface WelcomeController () <UIAlertViewDelegate>

@property BOOL loadedFirstTime;
@property BOOL needUpdate;

@property (atomic) BOOL _screen_lock;

@end

@implementation WelcomeController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self._screen_lock = NO;
    
    self.loadedFirstTime = YES;
    self.needUpdate = NO;
    
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
        
        float curVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"] floatValue];
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] getMinimumAppVersionWithSuccess:^(float minimumAppVersion) {
            if(curVersion < minimumAppVersion) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                self.needUpdate = YES;
                [self setInterfaceEnabled:NO];
                [self showVertionAlert];
            } else {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                
                [[ApiRequester sharedInstance] getAccountWithSuccess:^(UserProfile *profile) {
                    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                   
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
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
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
    
    if ([self tryLock])
    {
        FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
        login.loginBehavior = FBSDKLoginBehaviorSystemAccount;

        __weak WelcomeController* reference = self;

        [login logInWithReadPermissions:@[@"email"] fromViewController:self handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            if (error) {
                NSLog(@"FB login error: %@", [error description]);
            } else if (result.isCancelled) {
                NSLog(@"FB login cancelled");
            } else {
    //            [defs setObject:result.token.tokenString forKey:@"fbToken"];
                
                [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
                [[ApiRequester sharedInstance] loginWithFBToken:result.token.tokenString success:^(BOOL loggedIn, UserProfile* profile) {
                    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    
                    [DataCache sharedInstance].userProfile = profile;
                    if(loggedIn) {
                        if([profile isFilled]) {
                            [reference performSegueWithIdentifier:@"showMainScreenSegue" sender:reference];
                        } else {
                            [reference performSegueWithIdentifier:@"moreDetailsSegue" sender:reference];
                        }
                    } else {
                        [reference performSegueWithIdentifier:@"FBRegistrationSegue" sender:reference];
                    }
                } failure:^(NSString *error) {
                    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    [GlobalHelper showMessage:error withTitle:@"Login error"];
                    
                    [reference releaseLock];
                }];
            }
        }];
    }
}

-(IBAction)unwindToWelcomeController:(UIStoryboardSegue*)sender {
    NSLog(@"unwindToWelcomeController");
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return [self tryLock];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"moreDetailsSegue"]) {
        FBRegistrationController* controller = segue.destinationViewController;
        controller.updatingProfile = YES;
    }
    
    [self releaseLockWDelay];
}

#pragma mark - UIAlertViewDelegate

-(void)showVertionAlert {
    if(self.needUpdate) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"version check" message:DefAppOutdated delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://"]];
}

#pragma mark -

-(void)setInterfaceEnabled:(BOOL)enabled {
    [self.signInButton setEnabled:enabled];
    [self.signUpButton setEnabled:enabled];
    [self.signUpFBButton setEnabled:enabled];
}

#pragma Lock
- (BOOL) tryLock
{
    if (self._screen_lock)
    {
        return NO;
    }
    else
    {
        self._screen_lock = YES;
        
        return YES;
    }
}

- (void) releaseLockWDelay
{
    [self performSelector:@selector(releaseLock) withObject:nil afterDelay:0.5];
}

- (void) releaseLock
{
    self._screen_lock = NO;
}
@end
