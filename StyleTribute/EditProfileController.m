//
//  EditProfileController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "EditProfileController.h"
#import "DataCache.h"

@implementation EditProfileController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    
    UserProfile* profile = [DataCache sharedInstance].userProfile;
    self.emailField.text = profile.email;
    self.firstNameField.text = profile.firstName;
    self.lastNameField.text = profile.lastName;
    self.userNameField.text = profile.userName;
}

-(IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromEditProfile" sender:self];
}

-(IBAction)save:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromEditProfile" sender:self];
}

@end
