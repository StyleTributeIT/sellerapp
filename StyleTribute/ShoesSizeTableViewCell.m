//
//  ShoesSizeTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ShoesSizeTableViewCell.h"
#import "DataCache.h"
#import "GlobalDefs.h"
#import "GlobalHelper.h"
#import <NSArray+LinqExtensions.h>
#import <NSDictionary+LinqExtensions.h>
#import <MRProgress.h>
#import "AppDelegate.h"
#import <ActionSheetStringPicker.h>

@implementation ShoesSizeTableViewCell
UIPickerView* picker;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.shoeSize.delegate = self;
    self.shoeSize.inputView = picker;
}

-(void)setup
{
    self.shoeSize.frame = CGRectMake(4, 0, (self.frame.size.width - 8)/2, self.frame.size.height);
    self.heelHeight.frame = CGRectMake((self.frame.size.width - 8)/2 + 2, 0, (self.frame.size.width - 8)/2, self.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark UIPickerView delegate

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  [[DataCache sharedInstance].units  count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return @"---";
}

#pragma mark UITextField delegates

-(void)selectionWillChange:(id<UITextInput>)textInput{}

-(void)textDidChange:(id<UITextInput>)textInput
{
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.shoeSize])
    {
        NSArray *sizes = [NSArray arrayWithArray:[[DataCache sharedInstance].shoeSizes valueForKey:@"name"]];
        
        [ActionSheetStringPicker showPickerWithTitle:@""
                                                rows:sizes
                                    initialSelection:0
                                           doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                               self.selectedSize = [[DataCache sharedInstance].shoeSizes objectAtIndex:selectedIndex];
                                               self.shoeSize.text = sizes[selectedIndex];
                                           }
                                         cancelBlock:nil
                                              origin:self];
        
        [self.heelHeight resignFirstResponder];
        [textField resignFirstResponder];
    }
}

@end
