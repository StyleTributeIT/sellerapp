//
//  ChooseCategoryController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 05/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Category.h"

@interface ChooseCategoryController : UITableViewController

@property IBOutlet UITableView* categoriesTableView;
@property STCategory* selectedCategory;

@end
