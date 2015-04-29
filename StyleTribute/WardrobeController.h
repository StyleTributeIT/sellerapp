//
//  WardrobeController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <MGSwipeTableCell.h>
#import <UIKit/UIKit.h>

@interface WardrobeController : UIViewController<UITableViewDataSource,UITableViewDelegate,MGSwipeTableCellDelegate>

@property IBOutlet UISegmentedControl* wardrobeType;
@property IBOutlet UITableView* itemsTable;

-(IBAction)wardrobeTypeChanged:(id)sender;

@end
