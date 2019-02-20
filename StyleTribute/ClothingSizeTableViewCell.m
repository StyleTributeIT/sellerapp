//
//  ClothingSizeTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ClothingSizeTableViewCell.h"
#import <ActionSheetStringPicker.h>

@implementation ClothingSizeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.cloathSize.delegate = self;
    self.cloathUnits.delegate = self;
}

-(void) setup
{
    self.cloathUnits.frame = CGRectMake(18, 0, (self.frame.size.width - 8)/2 - 18, self.frame.size.height);
    self.cloathSize.frame = CGRectMake((self.frame.size.width - 8)/2 + 10, 1, (self.frame.size.width - 8)/2 - 8, self.frame.size.height);
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(self.cloathUnits.frame.size.width - 1, 1, 1.f, self.cloathUnits.frame.size.height);
    bottomBorder.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f].CGColor;
    [self.cloathUnits.layer addSublayer:bottomBorder];
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
        NSArray *sizes = nil;
        if (![_sizesKey isEqualToString:@"kidzsize"])
        {
            sizes = [NSArray arrayWithArray:[[[DataCache sharedInstance].units valueForKey:self.cloathUnits.text] valueForKey:@"name"]];
        } else
        {
            sizes = [NSArray arrayWithArray:[[[DataCache sharedInstance].kidzSizes valueForKey:self.cloathUnits.text] valueForKey:@"name"]];
        }
        if (sizes.count == 0){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Select a unit of measurement first" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        [ActionSheetStringPicker showPickerWithTitle:@""
                                                rows:sizes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               self.selectedSize = [[[DataCache sharedInstance].units valueForKey:self.cloathUnits.text] objectAtIndex:selectedIndex];
                                               if (sizes.count > 0)
                                                   self.cloathSize.text = sizes[selectedIndex];
                                           }
                                         cancelBlock:nil
                                              origin:self];
    } else if (textField == self.cloathUnits)
    {
        
        NSArray *sizes = nil;
        if (![_sizesKey isEqualToString:@"kidzsize"])
        {
            sizes = [NSArray arrayWithArray:[[DataCache sharedInstance].units.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* unit1, NSString* unit2) {
                return [unit1 compare: unit2];
            }]];
        } else {
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
                                               self.selectedUnit = [[DataCache sharedInstance].shoeSizes objectAtIndex:selectedIndex];
                                               self.cloathUnits.text = sizes[selectedIndex];
                                               self.cloathSize.text = @"";
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
