//
//  PriceViewController.h
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseInputController.h"

@interface PriceViewController : BaseInputController
    @property (strong, nonatomic) IBOutlet UITextField *priceField;
-(IBAction)textFieldDidChange :(UITextField *)theTextField;
-(void)editForOwnPrice;
@end
