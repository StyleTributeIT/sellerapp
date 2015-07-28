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
#import "ApiRequester.h"
#import "DataCache.h"
#import "MainTabBarController.h"
#import <MRProgress.h>
#import "AddWardrobeItemController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <NSArray+LinqExtensions.h>
#import "Photo.h"

@interface WardrobeController()

@property NSMutableArray* sellingItems;
@property NSMutableArray* soldItems;
@property NSMutableArray* archivedItems;

@end

@implementation WardrobeController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    
    UIColor* pink = [UIColor colorWithRed:1 green:0 blue:102.0/255 alpha:1];
    self.wardrobeType.tintColor = pink;
    [[UITabBar appearance] setSelectedImageTintColor:pink];
    
    NSString* deviceToken = [DataCache sharedInstance].deviceToken;
    if(deviceToken != nil && deviceToken.length > 0) {
        [[ApiRequester sharedInstance] setDeviceToken:deviceToken success:^{
        } failure:^(NSString *error) {
        }];
    }
    
    [self updateProducts];
    
    NSDictionary* textAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:12],
                                      NSForegroundColorAttributeName: [UIColor colorWithRed:132.0/255 green:132.0/255 blue:132.0/255 alpha:1] };
    NSDictionary* selectedTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Gotham-Book" size:12],
                                              NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self.wardrobeType setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.wardrobeType setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
    self.wardrobeType.accessibilityLabel = @"Wardrobe items type";
}

-(void)updateProducts {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    if([DataCache sharedInstance].categories == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getCategories:^(NSArray *categories) {
            NSLog(@"getCategories finished");
            [DataCache sharedInstance].categories = categories;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
    }
    
    if([DataCache sharedInstance].designers == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getDesigners:^(NSArray *designers) {
            NSLog(@"getDesigners finished");
            [DataCache sharedInstance].designers = designers;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
    }
    
    if([DataCache sharedInstance].conditions == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getConditions:^(NSArray *conditions) {
            NSLog(@"getConditions finished");
            [DataCache sharedInstance].conditions = conditions;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
    }
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"first step done!");
        [[ApiRequester sharedInstance] getProducts:^(NSArray *products) {
            NSLog(@"getProducts finished");
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            // TODO: we should divide products array on three parts
            self.sellingItems = [products mutableCopy];
            [self.itemsTable reloadData];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
        }];
    });
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self getCurrentItemsArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WardrobeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"wardrobeCell" forIndexPath:indexPath];
    Product* p = [[self getCurrentItemsArray] objectAtIndex:indexPath.row];
    
    [cell.image setImage:[UIImage imageNamed:@"stub"]];
    if(p.photos.count > 0) {
        Photo* photo = [[p.photos linq_where:^BOOL(Photo* item) {
            if([item isKindOfClass:[Photo class]])
                return (item.thumbnailUrl.length > 0 || item.image != nil);
            else
                return NO;
        }] firstObject];
        
        if(photo != nil) {
            if(photo.image == nil)
                [cell.image sd_setImageWithURL:[NSURL URLWithString:photo.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"stub"]];
            else
                [cell.image setImage:photo.image];
        }
    }
    
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.title.text = p.name;
    cell.displayState.text = p.processStatus;
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
    MainTabBarController* tabController = (MainTabBarController*)self.tabBarController;
    AddWardrobeItemController* awic = (AddWardrobeItemController*)[[tabController.viewControllers objectAtIndex:1] visibleViewController];
    awic.curProduct = [[self getCurrentItemsArray] objectAtIndex:indexPath.row];
    [tabController setSelectedIndex:1];  // Go to item detail page
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

//===========================

-(IBAction)unwindToWardrobeItems:(UIStoryboardSegue*)sender {
//    UIViewController *sourceViewController = sender.sourceViewController;
    NSLog(@"unwindToWardrobeItems");
}

-(IBAction)cancelUnwindToWardrobeItems:(UIStoryboardSegue*)sender {
    //    UIViewController *sourceViewController = sender.sourceViewController;
    NSLog(@"cancelUnwindToWardrobeItems");
}

-(void)addNewProduct:(Product*)product {
    [self.sellingItems addObject:product];
    [self.itemsTable reloadData];
}

-(void)updateProductsList {
    [self.itemsTable reloadData];
}

@end
