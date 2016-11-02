//
//  WardrobeCell.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "MGSwipeTableCell.h"
#import <UIKit/UIKit.h>

@interface WardrobeCell : MGSwipeTableCell

@property IBOutlet UIImageView* image;
@property IBOutlet UILabel* title;
@property IBOutlet UILabel* displayState;
@property (strong, nonatomic) IBOutlet UILabel *status;

@end
