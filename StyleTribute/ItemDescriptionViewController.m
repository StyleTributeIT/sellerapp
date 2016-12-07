//
//  ItemDescriptionViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ItemDescriptionViewController.h"
#import "DataCache.h"
#import "UITextView+Placeholder.h"

@interface ItemDescriptionViewController ()
    @property (strong, nonatomic) IBOutlet UITextField *nameField;
@property (strong, nonatomic) IBOutlet UIView *borderedFrame;
    @property (strong, nonatomic) IBOutlet UITextView *descriptionField;
@end

@implementation ItemDescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.descriptionField.placeholder = @"Description";
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.borderedFrame.frame.size.height - 1, self.borderedFrame.frame.size.width, 1.0f);
    bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    [self.borderedFrame.layer addSublayer:bottomBorder];
    
    CALayer *descBorder = [CALayer layer];
    descBorder.frame = CGRectMake(0.0f, 0.f, self.borderedFrame.frame.size.width, 1.0f);
    descBorder.backgroundColor = [UIColor colorWithWhite:0.8f
                                                     alpha:1.0f].CGColor;
    [self.borderedFrame.layer addSublayer:descBorder];
    UIImage *buttonImage = [UIImage imageNamed:@"backBtn"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,14,23);
    [aButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.leftBarButtonItem = backButton;
}

-(void)viewDidAppear:(BOOL)animated
{
    self.selectedProduct = [DataCache getSelectedItem];
    self.nameField.text = self.selectedProduct.name;
    self.descriptionField.text = self.selectedProduct.descriptionText;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
    
- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    if (self.selectedProduct)
    {
        self.selectedProduct.name = self.nameField.text;
        self.selectedProduct.descriptionText = self.descriptionField.text;
    }
    [DataCache setSelectedItem:self.selectedProduct];
    [self.navigationController popViewControllerAnimated:YES];
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
