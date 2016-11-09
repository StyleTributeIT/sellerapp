//
//  PriceConditionTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 11/9/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PriceConditionTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *statusImage;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *subtitle;

@end
