//
//  GlobalHelper.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <KASlideShow.h>

@interface GlobalHelper : NSObject

+(void)addLogoToNavBar:(UINavigationItem*)item;
+(UIPickerView*)createPickerForFields:(NSArray*)fields;
+(void)showMessage:(NSString*)msg withTitle:(NSString*)title;
+(NSAttributedString*)linkWithString:(NSString*)string;
+(void)configureSlideshow:(KASlideShow*)slideShow;
+(void)showToastNotificationWithTitle:(NSString*)title subtitle:(NSString*)subtitle imageUrl:(NSString*)url;
+(void)askConfirmationWithTitle:(NSString*)title message:(NSString*)message yes:(void(^)())yesCallback no:(void(^)())noCallback;

@end
