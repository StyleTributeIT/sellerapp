//
//  GlobalHelper.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GlobalHelper : NSObject

+(void)addLogoToNavBar:(UINavigationItem*)item;
+(UIPickerView*)createPickerForFields:(NSArray*)fields withTarget:(id)target doneAction:(SEL)done cancelAction:(SEL)cancel;
+(void)showMessage:(NSString*)msg withTitle:(NSString*)title;

@end
