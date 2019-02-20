//
//  AttributedLabel.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 19.05.15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "AttributedLabel.h"

@implementation AttributedLabel

-(void)awakeFromNib {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    NSRange range = NSMakeRange(0, attrString.length);
    
    if(self.fontFamily.length > 0) {
        [attrString addAttribute:NSFontAttributeName value:[UIFont fontWithName:self.fontFamily size:self.fontSize] range:range];
    }
    
    if(self.foregroundColor != nil) {
        [attrString addAttribute:NSForegroundColorAttributeName value:self.foregroundColor range:range];
    }
    
    if(self.isUnderlined) {
        [attrString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:range];
    }
    
    if(self.kerning > 0) {
        [attrString addAttribute:NSKernAttributeName value:@(self.kerning) range:range];
    }
    
    self.attributedText = attrString;
}

@end
