//
//  WardrobeController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <MGSwipeButton.h>

#import "GlobalHelper.h"
#import "Product.h"
#import "WardrobeCell.h"
#import "WardrobeController.h"

@interface WardrobeController()

@property NSMutableArray* sellingItems;
@property NSMutableArray* soldItems;
@property NSMutableArray* archivedItems;

@end

@implementation WardrobeController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self generateFakeData];
    [GlobalHelper addLogoToNavBar:self.navigationItem];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getCurrentItemsArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WardrobeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wardrobeCell" forIndexPath:indexPath];
    Product* p = [[self getCurrentItemsArray] objectAtIndex:indexPath.row];
    
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.title.text = p.title;
    cell.displayState.text = p.displayState;
    [cell.displayState sizeToFit];
    
    MGSwipeButton* delButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"remove"] backgroundColor:[UIColor redColor] insets:UIEdgeInsetsMake(10, 0, 10, 0)];
    delButton.buttonWidth = 48;
    MGSwipeButton* archiveButton = [MGSwipeButton buttonWithTitle:@"Archive" backgroundColor:[UIColor darkGrayColor]];
    
    cell.rightButtons = @[ delButton, archiveButton ];
    cell.rightSwipeSettings.transition = MGSwipeTransition3D;
    cell.allowsButtonsWithDifferentWidth = YES;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - MGSwipeTableCellDelegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    NSInteger itemIndex = cell.tag;
    switch (index) {
        case 0: {   // Delete button
            [[self getCurrentItemsArray] removeObjectAtIndex:itemIndex];
            [self.itemsTable reloadData];
            break;
        }
        
        default:
            break;
    }
    
    return TRUE;
}

#pragma mark - Other

-(IBAction)wardrobeTypeChanged:(id)sender {
    [self.itemsTable reloadData];
}

-(NSMutableArray*)getCurrentItemsArray {
    switch(self.wardrobeType.selectedSegmentIndex) {
        case 0: return self.sellingItems;
        case 1: return self.soldItems;
        case 2: return self.archivedItems;
        default: return nil;
    }
}

-(void)generateFakeData {
    self.sellingItems = [NSMutableArray new];
    self.soldItems = [NSMutableArray new];
    self.archivedItems = [NSMutableArray new];
    
    for (int i = 0; i < 15; ++i) {
        Product* p1 = [Product new];
        p1.title = [NSString stringWithFormat:@"selling %d", i];
        p1.displayState = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
        [self.sellingItems addObject:p1];
        
        Product* p2 = [Product new];
        p2.title = [NSString stringWithFormat:@"sold %d", i];
        p2.displayState = @"display state";
        [self.soldItems addObject:p2];
        
        Product* p3 = [Product new];
        p3.title = [NSString stringWithFormat:@"archived %d", i];
        p3.displayState = @"display state";
        [self.archivedItems addObject:p3];
    }
}

//===========================

-(IBAction)unwindToWardrobeItems:(UIStoryboardSegue*)sender {
    UIViewController *sourceViewController = sender.sourceViewController;
}

@end
