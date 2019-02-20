//
//  ShoesSizeTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ShoesSizeTableViewCell.h"
#import <ActionSheetStringPicker.h>
#import "XCDFormInputAccessoryView.h"

@implementation ShoesSizeTableViewCell
UIPickerView* picker;

- (void)awakeFromNib {
    [super awakeFromNib];
    self.shoeSize.delegate = self;
    self.shoeSize.inputView = picker;
}

-(void)setup
{
    self.shoeSize.frame = CGRectMake(18, 0, (self.frame.size.width - 8)/2 - 18, self.frame.size.height);
    self.heelHeight.frame = CGRectMake((self.frame.size.width - 8)/2 + 10, 1, (self.frame.size.width - 8)/2 - 8, self.frame.size.height - 1);
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(self.shoeSize.frame.size.width - 1, 1, 1.f, self.shoeSize.frame.size.height - 1);
    bottomBorder.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f].CGColor;
    [self.shoeSize.layer addSublayer:bottomBorder];
    self.shoeSize.delegate = self.heelHeight.delegate = self;
}

-(void)inputDone
{
    
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 5;
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
