//
//  QuestionViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "QuestionViewController.h"
#import "PriceViewController.h"
#import "Product.h"

@interface QuestionViewController ()
    @property (strong, nonatomic) IBOutlet UITextField *priceField;

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    self.hideNavButtons = YES;
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.priceField.frame.size.height - 1, self.priceField.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    [self.priceField.layer addSublayer:bottomBorder];
    Product *product = [DataCache getSelectedItem];
    product.originalPrice = 0;
    [DataCache setSelectedItem:product];
    UIImage *buttonImage = [UIImage imageNamed:@"backBtn"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,14,23);
    [aButton addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

-(void)viewDidDisappear:(BOOL)animated
{
    
}

- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)inputDone {
 //   Product *p = [DataCache getSelectedItem];
    int new_price = [self.priceField.text intValue];
    
 //   bool is_editing = [DataCache sharedInstance].isEditingItem;
    
   /* if (is_editing == true){
        if (new_price > p.price && p.price != 0)
        {
            NSString *str = [NSString stringWithFormat:@"New price cannot be higher than original price of $%.02f", p.price];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:str delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        else if (new_price == 0){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"New price cannot be empty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }*/
    if (new_price == 0){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Price cannnot be 0" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self nextPressed:nil];
}
- (IBAction)nextPressed:(id)sender {
    [self.priceField resignFirstResponder];
    if (!self.priceField.hidden)
    {
        if (self.priceField.text.length != 0)
        {
            Product *product = [DataCache getSelectedItem];
            product.originalPrice = [self.priceField.text floatValue];
            [DataCache setSelectedItem:product];
        } else
        {
            [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
            return;
        }
        self.priceField.hidden = YES;
        [self performSegueWithIdentifier:@"yesSegue" sender:nil];
    } else
    {
        Product *product = [DataCache getSelectedItem];
        product.originalPrice = 0;
        [DataCache setSelectedItem:product];
        self.priceField.text = @"";
        [self.priceField resignFirstResponder];
        [self performSegueWithIdentifier:@"priceSegue" sender:self];
    }
}

- (IBAction)yesPressed:(id)sender {
    [self.priceField becomeFirstResponder];
    self.priceField.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.priceField.text = @"";
    if ([segue.identifier isEqualToString:@"priceSegue"])
    {
        [((PriceViewController*)segue.destinationViewController) editForOwnPrice];
    }
}


@end
