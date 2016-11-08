//
//  QuestionViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "QuestionViewController.h"
#import "Product.h"
#import "DataCache.h"

@interface QuestionViewController ()
    @property (strong, nonatomic) IBOutlet UITextField *priceField;

@end

@implementation QuestionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.priceField.frame.size.height - 1, self.priceField.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    [self.priceField.layer addSublayer:bottomBorder];
}
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)nextPressed:(id)sender {
    if (self.priceField.text.length != 0)
    {
        Product *product = [DataCache getSelectedItem];
        product.price = [self.priceField.text floatValue];
        [DataCache setSelectedItem:product];
    }
    [self performSegueWithIdentifier:@"priceSegue" sender:self];
}
    
- (IBAction)yesPressed:(id)sender {
    self.priceField.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
