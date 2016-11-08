//
//  ClothingSizeTableViewCell.h
//  StyleTribute
//
//  Created by Mcuser on 11/8/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClothingSizeTableViewCell : UITableViewCell
    @property (strong, nonatomic) IBOutlet UITextField *cloathUnits;
    @property (strong, nonatomic) IBOutlet UITextField *cloathSize;
-(void) setup;
@end
