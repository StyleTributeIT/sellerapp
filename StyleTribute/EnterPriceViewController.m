//
//  EnterPriceViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/10/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "EnterPriceViewController.h"
#import "DataCache.h"
#import "GlobalHelper.h"
#import "ApiRequester.h"
#import <MRProgress.h>

@interface EnterPriceViewController ()
@property (strong, nonatomic) IBOutlet UITextField *priceField;
@property (strong, nonatomic) IBOutlet UITextField *priceEarned;
@property BOOL isInProgress;
@property (strong, nonatomic) IBOutlet UILabel *earnLabel;
@property (strong, nonatomic) IBOutlet UILabel *enterPriceLabel;
@property (strong, nonatomic) IBOutlet UIView *earnPriceView;
@property (strong, nonatomic) IBOutlet UIView *stPriceView;

@end

@implementation EnterPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.priceField becomeFirstResponder];
    self.earnPriceView.layer.borderColor = [UIColor colorWithRed:178.f/255.f green:178/255.f blue:178/255.f alpha:1.f].CGColor;
    self.stPriceView.layer.borderColor = [UIColor colorWithRed:178.f/255.f green:178/255.f blue:178/255.f alpha:1.f].CGColor;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)next:(id)sender {
    [self performSegueWithIdentifier:@"showResult" sender:self];
}

-(IBAction)textFieldDidChange :(UITextField *)theTextField{
    
}

-(void)inputDone {
    {
        [self.priceField resignFirstResponder];
        if(self.priceField.text.length > 0 && !self.isInProgress) {
            self.isInProgress = YES;
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            [[ApiRequester sharedInstance] getPriceSuggestionForProduct:[DataCache getSelectedItem] andOriginalPrice:[self.priceField.text floatValue] success:^(float priceSuggestion) {
                self.earnLabel.textColor = [UIColor colorWithRed:1.f green:64/255.f blue:140/255.f alpha:1.f];
                self.enterPriceLabel.textColor = [UIColor colorWithRed:1.f green:64/255.f blue:140/255.f alpha:1.f];
                self.earnPriceView.layer.borderColor = [UIColor colorWithRed:1.f green:64/255.f blue:140/255.f alpha:1.f].CGColor;
                self.priceEarned.text = [NSString stringWithFormat:@" $%.2f", priceSuggestion];
                self.priceEarned.textColor = [UIColor colorWithRed:1.f green:64/255.f blue:140/255.f alpha:1.f];
                Product *p = [DataCache getSelectedItem];
               // p.price = [self.priceEarned.text floatValue];
                p.suggestedPrice = priceSuggestion;
                [DataCache setSelectedItem:p];
                self.isInProgress = NO;
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            } failure:^(NSString *error) {
                self.isInProgress = NO;
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            }];
        }
    }
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showResult"])
    {
        Product *product = [DataCache getSelectedItem];
        product.price = [[self.priceEarned.text stringByReplacingOccurrencesOfString:@"$" withString:@""] floatValue];
        [DataCache setSelectedItem:product];
    }
}


@end
