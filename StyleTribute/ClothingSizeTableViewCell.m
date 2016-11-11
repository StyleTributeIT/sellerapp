//
//  ClothingSizeTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ClothingSizeTableViewCell.h"
#import "DataCache.h"
#import "GlobalDefs.h"
#import "GlobalHelper.h"
#import <NSArray+LinqExtensions.h>
#import <NSDictionary+LinqExtensions.h>
#import <ActionSheetStringPicker.h>

@implementation ClothingSizeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cloathSize.delegate = self;
    self.cloathUnits.delegate = self;
}

-(void) setup
{
    self.cloathUnits.frame = CGRectMake(4, 0, (self.frame.size.width - 8)/2, self.frame.size.height);
    self.cloathSize.frame = CGRectMake((self.frame.size.width - 8)/2 + 2, 0, (self.frame.size.width - 8)/2, self.frame.size.height);
}
    
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark UITextField delegates

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.cloathSize)
    {
        NSArray *sizes = [NSArray arrayWithArray:[[[DataCache sharedInstance].units valueForKey:self.cloathUnits.text] valueForKey:@"name"]];
        
        [ActionSheetStringPicker showPickerWithTitle:@""
                                                rows:sizes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               self.selectedSize = [[DataCache sharedInstance].shoeSizes objectAtIndex:selectedIndex];
                                               self.cloathSize.text = sizes[selectedIndex];
                                           }
                                         cancelBlock:nil
                                              origin:self];
    } else if (textField == self.cloathUnits)
    {
        
        NSArray *sizes = [NSArray arrayWithArray:[[DataCache sharedInstance].units.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* unit1, NSString* unit2) {
            return [unit1 compare: unit2];
        }]];
        
        [ActionSheetStringPicker showPickerWithTitle:@""
                                                rows:sizes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               self.selectedUnit = [[DataCache sharedInstance].shoeSizes objectAtIndex:selectedIndex];
                                               self.cloathUnits.text = sizes[selectedIndex];
                                               self.cloathSize.text = @"";
                                           }
                                         cancelBlock:nil
                                              origin:self];
    }
}

@end
