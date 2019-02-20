//
//  ChooseBrandController.h
//  StyleTribute
//
//  Created by selim mustafaev on 11/09/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product.h"

@interface ChooseBrandController : UIViewController

@property (weak) Product* product;

@property IBOutlet UITableView* tableView;
@property IBOutlet UISearchBar* searchBar;
@end
