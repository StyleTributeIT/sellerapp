//
//  GlobalHelper.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalHelper.h"
#import "SlideShowDataSource.h"
#import <CRToast.h>

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

+(void)showToastNotificationWithTitle:(NSString*)title subtitle:(NSString*)subtitle {
    NSDictionary *options = @{
                              kCRToastTextKey : title,
                              kCRToastSubtitleTextKey: subtitle,
                              kCRToastSubtitleTextMaxNumberOfLinesKey: @(2),
                              kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastSubtitleTextAlignmentKey: @(NSTextAlignmentLeft),
                              kCRToastNotificationTypeKey: @(CRToastTypeNavigationBar),
                              kCRToastNotificationPreferredPaddingKey: @(4),
                              kCRToastFontKey: [UIFont fontWithName:@"Montserrat-Regular" size:16],
                              kCRToastSubtitleFontKey: [UIFont fontWithName:@"Montserrat-Light" size:12],
//                              kCRToastImageKey: image,
                              kCRToastBackgroundColorKey : [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              };
    
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"notification completed");
                                }];
}

+(NSAttributedString*)linkWithString:(NSString*)string {
    return [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Montserrat-UltraLight" size:16], NSForegroundColorAttributeName: [UIColor colorWithRed:1.0 green:0.0 blue:102.0/256 alpha:1], NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}];
}

+(void)configureSlideshow:(KASlideShow*)slideShow {
    [slideShow setDelay:4];
    [slideShow setTransitionDuration:1];
    [slideShow setTransitionType:KASlideShowTransitionSlide];
    [slideShow setImagesContentMode:UIViewContentModeScaleAspectFit];
    [slideShow setDataSource:[SlideShowDataSource sharedInstance]];
}

@end
