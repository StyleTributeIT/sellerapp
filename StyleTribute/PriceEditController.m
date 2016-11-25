//
//  PriceEditController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 05/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "PriceEditController.h"

@interface PriceEditController ()

@property BOOL isInProgress;

@end

@implementation PriceEditController

-(void)viewDidLoad {
    [super viewDidLoad];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    [self hideAdvice];
    self.isInProgress = NO;
    
    if(self.product.originalPrice > 0) {
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] getPriceSuggestionForProduct:self.product andOriginalPrice:self.product.originalPrice success:^(float priceSuggestion) {
            self.suggestedPrice.text = [NSString stringWithFormat:@"%.2f", priceSuggestion];
            [self updateAdvice];
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        }];
    }
    
    self.originalPrice.text = self.product.originalPrice > 0 ? [NSString stringWithFormat:@"%.2f", self.product.originalPrice] : @"";
    self.userPrice.text = self.product.price > 0 ? [NSString stringWithFormat:@"%.2f", self.product.price] : @"";
    self.suggestedPrice.text = self.product.suggestedPrice > 0 ? [NSString stringWithFormat:@"%.2f", self.product.suggestedPrice] : @"";
    [self updateTakeback];
    
    [self updateAdvice];
}

#pragma mark - UITextFieldDelegate

-(void)inputDone {
    if(self.activeField == self.originalPrice) {
        [self.activeField resignFirstResponder];
        if(self.originalPrice.text.length > 0 && !self.isInProgress) {
            self.isInProgress = YES;
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            [[ApiRequester sharedInstance] getPriceSuggestionForProduct:self.product andOriginalPrice:[self.originalPrice.text floatValue] success:^(float priceSuggestion) {
                self.suggestedPrice.text = [NSString stringWithFormat:@"%.2f", priceSuggestion];
                if(self.userPrice.text.length == 0) {
                    self.userPrice.text = [NSString stringWithFormat:@"%.2f", priceSuggestion];
                }
                [self updateAdvice];
                [self updateTakeback];
                self.isInProgress = NO;
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            } failure:^(NSString *error) {
                self.isInProgress = NO;
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            }];
        }
    } else if(self.activeField == self.userPrice) {
        if(self.suggestedPrice.text.length > 0 && self.userPrice.text.length > 0) {
            [self updateAdvice];
            [self updateTakeback];
        }
        [self.activeField resignFirstResponder];
    }
}

-(IBAction)textFieldDidChange :(UITextField *)theTextField {
    if(self.activeField == theTextField) {
        [self updateAdvice];
        [self updateTakeback];
    }
}

#pragma mark - Helpers

-(void)updateAdvice {
    float suggestedPrice = [self.suggestedPrice.text floatValue];
    float userPrice = [self.userPrice.text floatValue];
    
    if(suggestedPrice > 0) {
        if(userPrice > suggestedPrice*1.1) {
            [self setAdvice:DefHighPriceAdvice];
        } else if(userPrice < suggestedPrice*0.9) {
            [self setAdvice:DefLowPriceAdvice];
        } else {
            [self hideAdvice];
        }
    }
}

-(void)hideAdvice {
    self.sellingAdviceLabel.text = @"";
    self.sellingAdviceText.text = @"";
}

-(void)setAdvice:(NSString*)text {
    self.sellingAdviceLabel.text = @"SELLING ADVICE:";
    self.sellingAdviceText.text = text;
}

-(void)updateTakeback {
    if(self.userPrice.text.length > 0) {
        float userPrice = [self.userPrice.text floatValue];
        self.takeBack.text = [NSString stringWithFormat:@"%.2f", userPrice*0.85];
    }
}

#pragma mark - Actions

-(IBAction)done:(id)sender {
    if([self noEmptyFields]) {
        self.product.originalPrice = [self.originalPrice.text floatValue];
        self.product.price = [self.userPrice.text floatValue];
        self.product.suggestedPrice = [self.suggestedPrice.text floatValue];
        [self performSegueWithIdentifier:@"unwindToAddItem" sender:self];
    } else {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
    }
}

-(IBAction)cancel:(id)sender {
    [self performSegueWithIdentifier:@"unwindToAddItem" sender:self];
}

#pragma mark -

-(BOOL)noEmptyFields {
    return (self.userPrice.text.length > 0 &&
            self.originalPrice.text.length > 0);
}

@end
