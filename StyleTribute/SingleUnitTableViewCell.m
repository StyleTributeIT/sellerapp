//
//  SingleUnitTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 1/16/17.
//  Copyright © 2017 Selim Mustafaev. All rights reserved.
//

#import "SingleUnitTableViewCell.h"
#import <ActionSheetStringPicker.h>

@implementation SingleUnitTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.unitField.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setup
{
    
}

#pragma mark UITextField delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
     if (textField == self.unitField)
    {
        
        NSArray *sizes = nil;
        {
            NSMutableArray* arr = [NSMutableArray new];
            for (NamedItem *dc in [DataCache sharedInstance].kidzSizes) {
                [arr addObject:dc.name];
            }
            sizes = [NSArray arrayWithArray:arr];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:@""
                                                rows:sizes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               self.selectedUnit = [[DataCache sharedInstance].kidzSizes objectAtIndex:selectedIndex];
                                               self.unitField.text = sizes[selectedIndex];
                                           }
                                         cancelBlock:nil
                                              origin:self];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 5;
}

@end
