//
//  ShoesSizeTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShoesSizeTableViewCell : UITableViewCell<UIPickerViewDelegate, UIPickerViewDataSource, UITextInputDelegate>
    @property (strong, nonatomic) IBOutlet UITextField *shoeSize;
    @property (strong, nonatomic) IBOutlet UITextField *heelHeight;

-(void) setup;
@end
