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

+(UIPickerView*)createPickerForFields:(NSArray*)fields {
    UIPickerView* picker = [[UIPickerView alloc] init];
    
    for (UITextField* field in fields) {
        field.inputView = picker;
    }
    
    return picker;
}

+(void)showMessage:(NSString*)msg withTitle:(NSString*)title {
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:title message:msg
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [message show];
}

@end
