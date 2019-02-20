//
//  AttributedLabel.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 19.05.15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface AttributedLabel : UILabel

@property IBInspectable NSString* fontFamily;
@property IBInspectable NSInteger fontSize;
@property IBInspectable CGFloat kerning;
@property IBInspectable UIColor* foregroundColor;
@property IBInspectable BOOL isUnderlined;

@end
