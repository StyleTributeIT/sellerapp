//
//  BankDetailsController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 07/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BankDetailsController.h"

@implementation BankDetailsController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    
    BankAccount* account = [DataCache sharedInstance].bankAccount;
//    [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
//    [[ApiRequester sharedInstance] getBankAccount:^(BankAccount* account){
//        [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        self.bankNameField.text = account.bankName;
        self.swiftCodeField.text = account.bankCode;
        self.holderNameField.text = account.beneficiary;
        self.accountNumberField.text = account.accountNumber;
        self.branchCodeField.text = account.branchCode;
//    } failure:^(NSString *error) {
//        [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
//    }];
}

-(IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindFromBankDetails" sender:self];
}

-(IBAction)save:(id)sender {
    if([self noEmptyFields]) {
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] setBankAccountWithBankName:self.bankNameField.text
                                                         bankCode:self.swiftCodeField.text
                                                      beneficiary:self.holderNameField.text
                                                    accountNumber:self.accountNumberField.text
                                                       branchCode:self.branchCodeField.text
                                                          success:^{
                                                              [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                                              [self performSegueWithIdentifier:@"unwindFromBankDetails" sender:self];
                                                          } failure:^(NSString *error) {
                                                              [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                                                              [GlobalHelper showMessage:error withTitle:@"Save bank details error"];
                                                          }];
    } else {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
    }
}

-(BOOL)noEmptyFields {
    return (self.bankNameField.text.length > 0 &&
            self.swiftCodeField.text.length > 0 &&
            self.holderNameField.text.length > 0 &&
            self.accountNumberField.text.length > 0 &&
            self.branchCodeField.text.length > 0);
}

@end
