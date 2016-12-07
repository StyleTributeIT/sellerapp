//
//  NotificationTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 12/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotificationTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UILabel *title;
@property (strong, nonatomic) IBOutlet UILabel *message;

@end