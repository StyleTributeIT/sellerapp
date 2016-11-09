//
//  PriceViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "PriceViewController.h"
#import "DataCache.h"

@interface PriceViewController ()
    @property (strong, nonatomic) IBOutlet UILabel *priceEarned;

@end

@implementation PriceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([DataCache getSelectedItem].price != 0.0f)
        self.priceField.text = [NSString stringWithFormat:@"%f", [DataCache getSelectedItem].price];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goNext:(id)sender {
    
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
