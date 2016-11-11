//
//  ShoesSizeTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NamedItems.h"

@interface ShoesSizeTableViewCell : UITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource, UITextInputDelegate>
@property (strong, nonatomic) IBOutlet UITextField *shoeSize;
@property (strong, nonatomic) IBOutlet UITextField *heelHeight;
@property NamedItem *selectedSize;

-(void) setup;
@end
