//
//  GlobalHelper.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "SlideShowDataSource.h"

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

+(NSAttributedString*)linkWithString:(NSString*)string {
    return [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Gotham-Light" size:16], NSForegroundColorAttributeName: [UIColor colorWithRed:1.0 green:0.0 blue:102.0/256 alpha:1], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
}

+(void)configureSlideshow:(KASlideShow*)slideShow {
    [slideShow setDelay:6];
    [slideShow setTransitionDuration:1];
    [slideShow setTransitionType:KASlideShowTransitionFade];
    [slideShow setImagesContentMode:UIViewContentModeScaleAspectFill];
    [slideShow setDataSource:[SlideShowDataSource sharedInstance]];
//    [slideShow addImage:[UIImage imageNamed:@"1.jpg"]];
//    [slideShow addImage:[UIImage imageNamed:@"2.jpg"]];
//    [slideShow addImage:[UIImage imageNamed:@"3.jpg"]];
//    [slideShow addImage:[UIImage imageNamed:@"4.jpg"]];
//    [slideShow addImage:[UIImage imageNamed:@"5.jpg"]];
//    [slideShow addImage:[UIImage imageNamed:@"6.jpg"]];
//    [slideShow addImage:[UIImage imageNamed:@"7.jpg"]];
//    [slideShow addImage:[UIImage imageNamed:@"8.jpg"]];
}

@end
