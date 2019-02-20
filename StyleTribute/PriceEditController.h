//
//  PriceEditController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 05/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"
#import "Product.h"

@interface PriceEditController : BaseInputController

@property IBOutlet UITextField* originalPrice;
@property IBOutlet UITextField* suggestedPrice;
@property IBOutlet UITextField* userPrice;
@property IBOutlet UITextField* takeBack;
@property IBOutlet UILabel* sellingAdviceLabel;
@property IBOutlet UILabel* sellingAdviceText;

@property (weak) Product* product;

-(IBAction)textFieldDidChange :(UITextField *)theTextField;

@end
