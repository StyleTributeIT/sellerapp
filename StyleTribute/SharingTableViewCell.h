//
//  SharingTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 11/19/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SharingTableViewCellDelegate
-(void)shareTwitt:(UIViewController*)vc;
-(void)shareFB;
@end

@interface SharingTableViewCell : UITableViewCell
@property (strong) id<SharingTableViewCellDelegate> delegate;
@end