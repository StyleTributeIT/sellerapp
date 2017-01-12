//
//  BagSizeTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "BagSizeTableViewCell.h"

@implementation BagSizeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void) setup
{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(self.bagWidth.frame.size.width - 1, 1, 1.f, self.frame.size.height);
    bottomBorder.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f].CGColor;
    [self.bagWidth.layer addSublayer:bottomBorder];
    CALayer *rightborder = [CALayer layer];
    rightborder.frame = CGRectMake(self.bagHeight.frame.size.width - 1, 1, 1.f, self.frame.size.height);
    rightborder.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f].CGColor;
    [self.bagHeight.layer addSublayer:rightborder];
    
    CALayer * wrightborder = [CALayer layer];
    wrightborder.frame = CGRectMake(0, 1, 1.f, self.frame.size.height - 1);
    wrightborder.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f].CGColor;
    [self.bagHeight.layer addSublayer:wrightborder];
    self.bagDepth.delegate = self.bagWidth.delegate = self.bagHeight.delegate = self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
