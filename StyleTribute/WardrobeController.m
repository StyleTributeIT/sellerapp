//
//  WardrobeController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "MGSwipeButton.h"

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
@property UIRefreshControl* refreshControl;

@end

@implementation WardrobeController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self updateWelcomeView];
    
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
    
    NSDictionary* textAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Light" size:12],
                                      NSForegroundColorAttributeName: [UIColor colorWithRed:132.0/255 green:132.0/255 blue:132.0/255 alpha:1] };
    NSDictionary* selectedTextAttributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Light" size:12],
                                              NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    [self.wardrobeType setTitleTextAttributes:textAttributes forState:UIControlStateNormal];
    [self.wardrobeType setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];
    self.wardrobeType.accessibilityLabel = @"Wardrobe items type";
	
	//_itemsTable.scrollIndicatorInsets=UIEdgeInsetsMake(64.0,0.0,44.0,0.0);
    
    NSDictionary* refreshTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Light" size:14]};
    self.refreshControl = [UIRefreshControl new];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating products" attributes:refreshTextAttributes];
    [self.refreshControl addTarget:self action:@selector(refreshProducts:) forControlEvents:UIControlEventValueChanged];
    [self.itemsTable insertSubview:self.refreshControl atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self updateProducts];
}

//-(void)viewDidAppear:(BOOL)animated{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [GlobalHelper showToastNotificationWithTitle:@"Test product" subtitle:@"Test message" imageUrl:/*@"http://image.made-in-china.com/2f0j00dvBQaODhfNkr/2011-Fashion-Women-High-Heel-Shoes-J85-.jpg"*/nil];
//    });
//}

-(void)updateProducts {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    if([DataCache sharedInstance].categories == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getCategories:^(NSArray *categories) {
            [DataCache sharedInstance].categories = categories;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
    }
    
    if([DataCache sharedInstance].designers == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getDesigners:^(NSArray *designers) {
            [DataCache sharedInstance].designers = designers;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
    }
    
    if([DataCache sharedInstance].conditions == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getConditions:^(NSArray *conditions) {
            [DataCache sharedInstance].conditions = conditions;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
    }
    
    if([DataCache sharedInstance].countries == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getCountries:^(NSArray *countries) {
            [DataCache sharedInstance].countries = countries;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
    }
    
    if([DataCache sharedInstance].shoeSizes == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getSizeValues:@"shoesize" success:^(NSArray *sizes) {
            [DataCache sharedInstance].shoeSizes = sizes;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
    }
	
	if([DataCache sharedInstance].units == nil) {
		dispatch_group_enter(group);
		[[ApiRequester sharedInstance] getUnitAndSizeValues:@"size" success:^(NSDictionary *units) {
			[DataCache sharedInstance].units = units;
			dispatch_group_leave(group);
		} failure:^(NSString *error) {
			dispatch_group_leave(group);
		}];
	}
	
    dispatch_group_notify(group, queue, ^{
        [[ApiRequester sharedInstance] getProducts:^(NSArray *products) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [DataCache sharedInstance].products = [products mutableCopy];
            [self storeProductsInGroups:products];
			[self.itemsTable reloadData];
			[self updateWelcomeView];
			
            if([DataCache sharedInstance].openProductOnstart > 0) {
                Product* p = [[[DataCache sharedInstance].products linq_where:^BOOL(Product* item) {
                    return (item.identifier == [DataCache sharedInstance].openProductOnstart);
                }] firstObject];
                [DataCache sharedInstance].openProductOnstart = 0;
                
                if(p != nil) {
                    [self openProductDetails:p];
                }
            }
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
    cell.displayState.text = p.processStatusDisplay;
    [cell.displayState sizeToFit];
    
    cell.rightButtons = [self rightButtonsForProduct:p];
    cell.rightSwipeSettings.transition = MGSwipeTransitionDrag;
    cell.allowsButtonsWithDifferentWidth = YES;
    
    return cell;
}

-(NSArray*)rightButtonsForProduct:(Product*)product {
    NSMutableArray* buttons = [NSMutableArray new];
    
    MGSwipeButton* delButton = [MGSwipeButton buttonWithTitle:@"" icon:[UIImage imageNamed:@"remove"] backgroundColor:[UIColor redColor] insets:UIEdgeInsetsMake(10, 10, 10, 10)];
    delButton.buttonWidth = 68;
    delButton.tag = 0;
    MGSwipeButton* archiveButton = [MGSwipeButton buttonWithTitle:@"Archive" backgroundColor:[UIColor darkGrayColor]];
    archiveButton.tag = 1;
    MGSwipeButton* suspendButton = [MGSwipeButton buttonWithTitle:@"Suspend" backgroundColor:[UIColor darkGrayColor]];
    suspendButton.tag = 2;
    MGSwipeButton* relistButton = [MGSwipeButton buttonWithTitle:@"re-list" backgroundColor:[UIColor darkGrayColor]];
    relistButton.tag = 3;
    
    if([product.allowedTransitions linq_any:^BOOL(NSString* transition) { return [transition isEqualToString:@"deleted"]; }]) {
        [buttons addObject:delButton];
    }
    
    if([product.allowedTransitions linq_any:^BOOL(NSString* transition) { return [transition isEqualToString:@"archived"]; }]) {
        [buttons addObject:archiveButton];
    }
    
    if([product.allowedTransitions linq_any:^BOOL(NSString* transition) { return [transition isEqualToString:@"suspended"]; }]) {
        [buttons addObject:suspendButton];
    }
    
    if([product.allowedTransitions linq_any:^BOOL(NSString* transition) { return [transition isEqualToString:@"selling"]; }]) {
        [buttons addObject:relistButton];
    }
    
    return buttons;
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
    [self openProductDetails:[[self getCurrentItemsArray] objectAtIndex:indexPath.row]];
}

-(void)openProductDetails:(Product*)product {
    MainTabBarController* tabController = (MainTabBarController*)self.tabBarController;
    AddWardrobeItemController* awic = (AddWardrobeItemController*)[[tabController.viewControllers objectAtIndex:1] visibleViewController];
    awic.curProduct = product;
    awic.isEditing = YES;
    [tabController setSelectedIndex:1];  // Go to item detail page
}

#pragma mark - MGSwipeTableCellDelegate

-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell tappedButton:(MGSwipeButton*)button AtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion {
    Product* p = [[self getCurrentItemsArray] objectAtIndex:cell.tag];
    NSString* newStatus = p.processStatus;
    NSString* warningMessage = nil;
    
    switch (button.tag) {
        case 0:  // Delete button
            newStatus = @"deleted";
            warningMessage = DefProductDeleteWarning;
            break;
        case 1:  // Archive button
            newStatus = @"archived";
            break;
        case 2:  // Suspend button
            newStatus = @"suspended";
            break;
        case 3:  // re-list button
            newStatus = @"selling";
            break;
        
        default:
            break;
    }
    
    if(warningMessage) {
        [GlobalHelper askConfirmationWithTitle:@"" message:warningMessage yes:^{
            [self setStatus:newStatus forProduct:p];
        } no:nil];
    } else {
        [self setStatus:newStatus forProduct:p];
    }
    
    return TRUE;
}

-(void)setStatus:(NSString*)status forProduct:(Product*)p {
    [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    [[ApiRequester sharedInstance] setProcessStatus:status forProduct:p.identifier success:^(Product *product) {
        [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        p.processStatus = product.processStatus;
        p.processStatusDisplay = product.processStatusDisplay;
        [self storeProductsInGroups:[DataCache sharedInstance].products];
        [self.itemsTable reloadData];
        [self updateWelcomeView];
    } failure:^(NSString *error) {
        [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
        [GlobalHelper showMessage:error withTitle:@"error"];
    }];
}

#pragma mark - Other

-(IBAction)wardrobeTypeChanged:(id)sender {
	[self.itemsTable reloadData];
	[self updateWelcomeView];
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
    [[DataCache sharedInstance].products addObject:product];
    [self storeProductsInGroups:[DataCache sharedInstance].products];
	[self.itemsTable reloadData];
	[self updateWelcomeView];
}

-(void)updateProductsList {
    [self storeProductsInGroups:[DataCache sharedInstance].products];
    [self.itemsTable reloadData];
	[self updateWelcomeView];
}

-(void)storeProductsInGroups:(NSArray*)products {
    self.sellingItems = [NSMutableArray new];
    self.soldItems = [NSMutableArray new];
    self.archivedItems = [NSMutableArray new];
    
    for (Product* product in products) {
        ProductType type = [product getProductType];
        
        switch (type) {
            case ProductTypeSelling:
                [self.sellingItems addObject:product];
                break;
            case ProductTypeSold:
                [self.soldItems addObject:product];
                break;
            case ProductTypeArchived:
                [self.archivedItems addObject:product];
                break;
                
            default:
                break;
        }
    }
}

- (void)updateWelcomeView {
	_welcomView.hidden = self.sellingItems.count || self.soldItems.count || self.archivedItems.count;
}

-(void)refreshProducts:(UIRefreshControl*)sender {
    NSLog(@"start refresh");
    [[ApiRequester sharedInstance] getProducts:^(NSArray *products) {
        [sender endRefreshing];
        [DataCache sharedInstance].products = [products mutableCopy];
        [self storeProductsInGroups:products];
        [self.itemsTable reloadData];
        [self updateWelcomeView];
        NSLog(@"stop refresh");
    } failure:^(NSString *error) {
        [sender endRefreshing];
        [GlobalHelper showMessage:error withTitle:@"error"];
    }];
}

@end
