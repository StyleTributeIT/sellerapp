//
//  ClothingSizeTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NamedItems.h"

@interface ClothingSizeTableViewCell : UITableViewCell<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *cloathUnits;
@property (strong, nonatomic) IBOutlet UITextField *cloathSize;
@property NSString* sizesKey;
@property NamedItem *selectedSize;
@property NamedItem *selectedUnit;
-(void) setup;
@end
