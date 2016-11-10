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
        [self.heelHeight resignFirstResponder];
        picker  = [GlobalHelper createPickerForFields:@[self.shoeSize]];
        picker.dataSource = self;
        picker.delegate = self;
        [picker reloadAllComponents];
        NSLog(@"Show picker for shoes");
        [picker selectRow:0 inComponent:0 animated:NO];
        [textField resignFirstResponder];
      /*  if([MRProgressOverlayView overlayForView:picker] == nil) {
            [MRProgressOverlayView showOverlayAddedTo:picker  title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:NO];
        } */
        
       // [[[[UIApplication sharedApplication] delegate] window] addSubview:picker];
     //   [self showPicker];
    }
}

- (IBAction)hidePicker {
    
    float pvHeight = 350;//pickerView.frame.size.height;
    float y = [UIScreen mainScreen].bounds.size.height - (pvHeight * -2); // the root view of view controller
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        picker.frame = CGRectMake(0 , y, picker.frame.size.width, pvHeight);
    } completion:nil];
}

- (IBAction)showPicker {
    float pvHeight = 350;//pickerView.frame.size.height;
    float y = [UIScreen mainScreen].bounds.size.height - (pvHeight); // the root view of view controller
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        picker.frame = CGRectMake(0 , y, picker.frame.size.width, pvHeight);
    } completion:nil];
}

@end
