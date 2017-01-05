//
//  PriceViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "PriceViewController.h"


@interface PriceViewController () <UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *priceEarned;
@property BOOL isInProgress;
@property BOOL isOwnPrice;
@property (strong, nonatomic) IBOutlet UIView *additionalButtons;
@property (strong, nonatomic) IBOutlet UILabel *earnTitle;
@end

@implementation PriceViewController

- (void)viewDidLoad {
    self.hideNavButtons = YES;
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
        Product *p = [DataCache getSelectedItem];
        //int original_price = p.originalPrice;
        
        //NSString *new_price = [self.priceField.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
        //int price = [new_price intValue];
        
        if (self.isOwnPrice == false){
            self.additionalButtons.hidden = NO;
            [[ApiRequester sharedInstance] getPriceSuggestionForProduct:p andOriginalPrice:p.originalPrice success:^(float priceSuggestion) {
                self.priceEarned.text = [NSString stringWithFormat:@"%.2f", priceSuggestion];
                
                [[ApiRequester sharedInstance] getSellerPayoutForProduct:p.category.idNum price:priceSuggestion success:^(float price) {
                    self.priceEarned.text = [NSString stringWithFormat:@"%.2f", price];
                    self.isInProgress = NO;
                    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                } failure:^(NSString *error) {
                    self.isInProgress = NO;
                    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                }];
                //[MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            } failure:^(NSString *error) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                self.isInProgress = NO;
            }];
            /*
            [[ApiRequester sharedInstance] getSellerPayoutForProduct:p.category.idNum price:original_price success:^(float price) {
                self.priceEarned.text = [NSString stringWithFormat:@" $%.2f", price];
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            } failure:^(NSString *error) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            }];*/
        }
        else{
            self.additionalButtons.hidden = YES;
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        }
    }
    self.priceField.text = [DataCache getSelectedItem].originalPrice > 0 ? [NSString stringWithFormat:@"%.2f", [DataCache getSelectedItem].originalPrice] : @"";
    self.priceField.delegate = self;
    UIImage *buttonImage = [UIImage imageNamed:@"backBtn"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,14,23);
    [aButton addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
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
        self.priceField.text = [NSString stringWithFormat:@"%.2f", [DataCache getSelectedItem].price];
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
            Product *p = [DataCache getSelectedItem];
            NSString *new_price = [self.priceField.text stringByReplacingOccurrencesOfString:@"$"
                                                                       withString:@""];
            int price = [new_price intValue];
            if (price > p.price && p.price != 0)
            {
                NSString *str = [NSString stringWithFormat:@"New price cannot be higher than original price of $%.02f", p.price];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            }
            self.isInProgress = YES;
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            
             [[ApiRequester sharedInstance] getPriceSuggestionForProduct:p andOriginalPrice:price success:^(float priceSuggestion) {
                 self.priceEarned.text = [NSString stringWithFormat:@"%.2f", priceSuggestion];
                 [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                 self.isInProgress = NO;
             } failure:^(NSString *error) {
                 [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                 self.isInProgress = NO;
             }];
/*
            [[ApiRequester sharedInstance] getSellerPayoutForProduct:p.category.idNum price:price success:^(float price) {
                self.priceEarned.text = [NSString stringWithFormat:@" $%.2f", price];
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                self.isInProgress = NO;
            } failure:^(NSString *error) {
                [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                self.isInProgress = NO;
            }];*/

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
