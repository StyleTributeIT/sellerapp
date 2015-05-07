//
//  BankDetailsController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "BankDetailsController.h"

@implementation BankDetailsController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
}

-(IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromBankDetails" sender:self];
}

-(IBAction)save:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromBankDetails" sender:self];
}

@end
