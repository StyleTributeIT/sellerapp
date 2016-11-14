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
@end

@implementation EnterPriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
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
                self.priceEarned.text = [NSString stringWithFormat:@" $%.2f", priceSuggestion];
                Product *p = [DataCache getSelectedItem];
                p.price = [self.priceField.text floatValue];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
