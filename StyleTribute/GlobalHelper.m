//
//  GlobalHelper.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "SlideShowDataSource.h"
#import <CRToast.h>
#import <SDWebImageDownloader.h>
#import <SDWebImageManager.h>
#import "UIAlertView+Blocks.h"

@implementation GlobalHelper

+(void)addLogoToNavBar:(UINavigationItem*)item {
    UIImageView *titleImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 35)];
    titleImg.image = [UIImage imageNamed:@"logo-1"];
    UIImageView *workaroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 34)];
    [workaroundImageView addSubview:titleImg];
    item.titleView = workaroundImageView;
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

+(void)showToastNotificationWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageUrl:(NSString*)url {
    NSMutableDictionary *options = [@{
                              kCRToastTextKey : title,
                              kCRToastSubtitleTextKey: subtitle,
                              kCRToastSubtitleTextMaxNumberOfLinesKey: @(2),
                              kCRToastTextAlignmentKey : @(NSTextAlignmentLeft),
                              kCRToastSubtitleTextAlignmentKey: @(NSTextAlignmentLeft),
                              kCRToastNotificationTypeKey: @(CRToastTypeNavigationBar),
                              kCRToastNotificationPreferredPaddingKey: @(4),
                              kCRToastFontKey: [UIFont fontWithName:@"Montserrat-Regular" size:16],
                              kCRToastSubtitleFontKey: [UIFont fontWithName:@"Montserrat-Light" size:12],
                              kCRToastBackgroundColorKey : [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8],
                              kCRToastAnimationInTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationOutTypeKey : @(CRToastAnimationTypeLinear),
                              kCRToastAnimationInDirectionKey : @(CRToastAnimationDirectionTop),
                              kCRToastAnimationOutDirectionKey : @(CRToastAnimationDirectionTop)
                              } mutableCopy];
    
    if(url) {
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:[NSURL URLWithString:url]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                 // progression tracking code
                             }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    UIImage* resizedImage = [GlobalHelper imageWithImage:image scaledToSize:CGSizeMake(48, 48)];
                                    [options setObject:resizedImage forKey:kCRToastImageKey];
                                    [CRToastManager showNotificationWithOptions:options
                                                                completionBlock:^{

                                                                }];
                                }
                            }];
    } else {
        [CRToastManager showNotificationWithOptions:options
                                    completionBlock:^{

                                    }];
    }
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

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(void)askConfirmationWithTitle:(NSString*)title message:(NSString*)message yes:(void(^)())yesCallback no:(void(^)())noCallback {
    [UIAlertView showWithTitle:title message:message cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] tapBlock: ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == [alertView cancelButtonIndex]) {
            if(noCallback)
                noCallback();
        } else {
            if(yesCallback)
                yesCallback();
        }
    }];
}

@end
