//
//  ChangePasswordController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ChangePasswordController.h"

@implementation ChangePasswordController

-(void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
}

-(IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromChangePassword" sender:self];
}

-(IBAction)save:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromChangePassword" sender:self];
}

@end
