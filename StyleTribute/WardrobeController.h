//
//  WardrobeController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Product.h"
#import "MGSwipeTableCell.h"
#import "ProductNavigationViewController.h"
#import <UIKit/UIKit.h>

@interface WardrobeController : UIViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>

@property IBOutlet UISegmentedControl* wardrobeType;
@property IBOutlet UITableView* itemsTable;
@property (weak, nonatomic) IBOutlet UIView *welcomView;

-(IBAction)wardrobeTypeChanged:(id)sender;
-(IBAction)unwindToWardrobeItems:(UIStoryboardSegue*)sender;

-(void)addNewProduct:(Product*)product;
-(void)updateProductsList;

@end
