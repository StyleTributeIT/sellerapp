//
//  SingleUnitTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 1/16/17.
//  Copyright © 2017 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NamedItems.h"

@interface SingleUnitTableViewCell : UITableViewCell<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *unitField;
@property NamedItem *selectedUnit;
-(void)setup;
@end
