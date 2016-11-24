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
    bottomBorder.frame = CGRectMake(self.bagWidth.frame.size.width - 1, 0, 1.f, self.frame.size.height);
    bottomBorder.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f].CGColor;
    [self.bagWidth.layer addSublayer:bottomBorder];
    CALayer *rightborder = [CALayer layer];
    rightborder.frame = CGRectMake(self.bagHeight.frame.size.width - 1, 0, 1.f, self.frame.size.height);
    rightborder.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f].CGColor;
    [self.bagHeight.layer addSublayer:rightborder];
}
    
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
