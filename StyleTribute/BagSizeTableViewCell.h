//
//  BagSizeTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BagSizeTableViewCell : UITableViewCell<UITextFieldDelegate>
    @property (strong, nonatomic) IBOutlet UITextField *bagWidth;
    @property (strong, nonatomic) IBOutlet UITextField *bagHeight;
    @property (strong, nonatomic) IBOutlet UITextField *bagDepth;
-(void) setup;
@end
