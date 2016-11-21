//
//  PriceViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "PriceViewController.h"
#import "DataCache.h"
#import "GlobalHelper.h"
#import "ApiRequester.h"
#import <MRProgress.h>

@interface PriceViewController ()
@property (strong, nonatomic) IBOutlet UITextField *priceEarned;
@property BOOL isInProgress;
@property BOOL isOwnPrice;
@property (strong, nonatomic) IBOutlet UIView *additionalButtons;
@property (strong, nonatomic) IBOutlet UILabel *earnTitle;
@end

@implementation PriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isInProgress = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    if (!self.isOwnPrice)
    {
        self.priceEarned.enabled = NO;
        self.priceField.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Done";
    }
    if([DataCache getSelectedItem].originalPrice > 0) {
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] getPriceSuggestionForProduct:[DataCache getSelectedItem] andOriginalPrice:[DataCache getSelectedItem].originalPrice success:^(float priceSuggestion) {
            self.priceEarned.text = [NSString stringWithFormat:@" $%.2f", priceSuggestion];
            if (!self.isOwnPrice)
                self.additionalButtons.hidden = NO;
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        }];
    }
    self.priceField.text = [DataCache getSelectedItem].originalPrice > 0 ? [NSString stringWithFormat:@" $%.2f", [DataCache getSelectedItem].originalPrice] : @"";
    UIImage *buttonImage = [UIImage imageNamed:@"backBtn"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,14,23);
    [aButton addTarget:self action:@selector(backPressed::) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (IBAction)acceptPrice:(id)sender {
    self.additionalButtons.hidden = YES;
    [self performSegueWithIdentifier:@"showResult" sender:nil];
}

- (IBAction)enterPrice:(id)sender {
    //[self.priceField becomeFirstResponder];
  //  [self performSegueWithIdentifier:@"enterOwnPriceSegue" sender:nil];
}

-(void)editForOwnPrice
{
    self.isOwnPrice = YES;
    self.priceField.enabled = YES;
    self.priceField.text = @"";
    
    [self.priceField becomeFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([DataCache sharedInstance].isEditingItem)
    {
        self.navigationItem.rightBarButtonItem.title = @"Done";
    } else
    {
        self.navigationItem.rightBarButtonItem.title = @"Next";
    }
    if (!self.isOwnPrice)
    if ([DataCache getSelectedItem].price != 0.0f)
        self.priceField.text = [NSString stringWithFormat:@" $%.2f", [DataCache getSelectedItem].price];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goNext:(id)sender {
    [self performSegueWithIdentifier:@"showResult" sender:nil];
}
    
-(IBAction)textFieldDidChange :(UITextField *)theTextField
{
    
}

-(void)inputDone {
    {
        [self.priceField resignFirstResponder];
        if(self.priceField.text.length > 0 && !self.isInProgress) {
            self.isInProgress = YES;
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            [[ApiRequester sharedInstance] getPriceSuggestionForProduct:[DataCache getSelectedItem] andOriginalPrice:[self.priceField.text floatValue] success:^(float priceSuggestion) {
                self.priceEarned.text = [NSString stringWithFormat:@" $%.2f", priceSuggestion];
                self.earnTitle.textColor = [UIColor colorWithRed:1.f green:64/255.f blue:140/255.f alpha:1.f];
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
