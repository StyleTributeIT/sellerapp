//
//  GlobalHelper.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"

@implementation GlobalHelper

+(void)addLogoToNavBar:(UINavigationItem*)item {
    UIImageView *titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    titleImg.image = [UIImage imageNamed:@"LogoHeader"];
    item.titleView = titleImg;
}

+(UIPickerView*)createPickerForFields:(NSArray*)fields withTarget:(id)target doneAction:(SEL)done cancelAction:(SEL)cancel {
    UIPickerView* picker = [[UIPickerView alloc] init];
    
    UIToolbar* pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    pickerToolbar.barTintColor = [UIColor grayColor];
    pickerToolbar.translucent = NO;
    UIBarButtonItem *barDone = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:target action:done];
    UIBarButtonItem *barCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:target action:cancel];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    pickerToolbar.items = @[barCancel, flexibleSpace, barDone];
    
    for (UITextField* field in fields) {
        field.inputView = picker;
        field.inputAccessoryView = pickerToolbar;
    }
    
    return picker;
}

@end
