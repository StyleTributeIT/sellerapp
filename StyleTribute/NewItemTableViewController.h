//
//  NewItemTableViewController.h
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface NewItemTableViewController : UITableViewController
@property Product* curProduct;
@property BOOL isEditingItem;
@end
