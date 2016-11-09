//
//  ClothingSizeTableViewCell.m
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "ClothingSizeTableViewCell.h"

@implementation ClothingSizeTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void) setup
{
    self.cloathUnits.frame = CGRectMake(4, 0, (self.frame.size.width - 8)/2, self.frame.size.height);
    self.cloathSize.frame = CGRectMake((self.frame.size.width - 8)/2 + 2, 0, (self.frame.size.width - 8)/2, self.frame.size.height);
}
    
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
