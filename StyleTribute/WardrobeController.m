//
//  WardrobeController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "MGSwipeButton.h"
#import "Product.h"
#import "WardrobeCell.h"
#import "WardrobeController.h"
#import "AddWardrobeItemController.h"
#import "NewItemTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Photo.h"
#import <ZDCChat/ZDCChat.h>

@interface WardrobeController()

@property NSMutableArray* sellingItems;
@property NSMutableArray* soldItems;
@property NSMutableArray* archivedItems;
@property UIRefreshControl* refreshControl;
@property (strong, nonatomic) IBOutlet UIView *tabsContainer;

@end

@implementation WardrobeController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self updateWelcomeView];
    
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    UIColor* pink = [UIColor colorWithRed:1 green:0 blue:102.0/255 alpha:1];
    self.wardrobeType.tintColor = pink;
    [[UITabBar appearance] setSelectedImageTintColor:pink];
    
    NSString* deviceToken = [DataCache sharedInstance].deviceToken;
    if(deviceToken != nil && deviceToken.length > 0) {
        [[ApiRequester sharedInstance] setDeviceToken:deviceToken success:^{
        } failure:^(NSString *error) {
        }];
        
    }
    [self.tabBarController.navigationController.navigationBar setShadowImage:[UIImage new]];

    UIBarButtonItem *supportBtn =[[UIBarButtonItem alloc]initWithTitle:@"Support" style:UIBarButtonItemStyleDone target:self action:@selector(popToSupport)];
    supportBtn.title = @"Support";
    [supportBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIFont fontWithName:@"Montserrat-Light" size:14], NSFontAttributeName,
                                        pink, NSForegroundColorAttributeName,
                                        nil]
                              forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = supportBtn;

    self.wardrobeType.accessibilityLabel = @"Wardrobe items type";
	
	//_itemsTable.scrollIndicatorInsets=UIEdgeInsetsMake(64.0,0.0,44.0,0.0);
    
    NSDictionary* refreshTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Montserrat-Light" size:14]};
    self.refreshControl = [UIRefreshControl new];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Updating products" attributes:refreshTextAttributes];
    [self.refreshControl addTarget:self action:@selector(refreshProducts:) forControlEvents:UIControlEventValueChanged];
    [self.itemsTable insertSubview:self.refreshControl atIndex:0];
    [self customizeSegment];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self updateProducts];
    self.itemsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}
- (void) popToSupport{
    [ZDCChat initializeWithAccountKey:DefZendeskKey];

    UserProfile* profile = [DataCache sharedInstance].userProfile;
    
    [ZDCChat updateVisitor:^(ZDCVisitorInfo *user) {
        user.phone = profile.phone;
        user.name = [NSString stringWithFormat:@"%@ %@", profile.firstName, profile.lastName];
        user.email = profile.email;
    }];
    
    // start a chat in a new modal
    [ZDCChat startChatIn:self.navigationController withConfig:^(ZDCConfig *config) {
        config.preChatDataRequirements.name = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.email = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.phone = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.department = ZDCPreChatDataOptionalEditable;
        config.preChatDataRequirements.message = ZDCPreChatDataOptionalEditable;
    }];
}

-(void)updateProducts {
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
    
    if([DataCache sharedInstance].categories == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getCategories:^(NSArray *categories) {
            NSLog(@"%@",categories);
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

   
	
    if([DataCache sharedInstance].units == nil) {
        dispatch_group_enter(group);
        [[ApiRequester sharedInstance] getUnitAndSizeValues:@"size" success:^(NSDictionary *units) {
            [DataCache sharedInstance].units = units;
            dispatch_group_leave(group);
        } failure:^(NSString *error) {
            dispatch_group_leave(group);
        }];
   }
	  [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 104.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *arr = [self getCurrentItemsArray];
    return arr!=nil?arr.count:0;
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
    UINavigationController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddItemNavController"];
    for(UIViewController * viewController in navController.viewControllers){
        if ([viewController isKindOfClass:[ProductNavigationViewController class]]){
            ProductNavigationViewController *vc = (ProductNavigationViewController * ) viewController;
            vc.curProduct = product;
          
            [DataCache setSelectedItem:product];
            [DataCache sharedInstance].isEditingItem = YES;
            break;
        }
    }
    [self presentViewController:navController animated:YES completion:nil] ;
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
        [self updateProducts];
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
}

-(IBAction)cancelUnwindToWardrobeItems:(UIStoryboardSegue*)sender {
    //    UIViewController *sourceViewController = sender.sourceViewController;
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
    _itemsTable.hidden = !(self.sellingItems.count || self.soldItems.count || self.archivedItems.count);
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

-(void) customizeSegment
{
    CGRect frame= self.wardrobeType.frame;
    [self.wardrobeType setFrame:CGRectMake(0, 0, frame.size.width, 45.f)];
    
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [[UIColor whiteColor] CGColor];
    upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.wardrobeType.frame), 0.5f);
    [self.tabsContainer.layer addSublayer:upperBorder];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                self.tabsContainer.frame.size.height - 1,
                                                                self.tabsContainer.frame.size.width, 1.f)];
    
    lineView.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f];
    [self.tabsContainer addSubview:lineView];
    
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, self.wardrobeType.frame.size.height - 1), NO, 2.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.wardrobeType setDividerImage:blank
                    forLeftSegmentState:UIControlStateNormal
                      rightSegmentState:UIControlStateNormal
                             barMetrics:UIBarMetricsDefault];
    
    [self.wardrobeType setBackgroundImage:[UIImage imageNamed:@"segmentNormal"]
                                       forState:UIControlStateNormal
                                     barMetrics:UIBarMetricsDefault];
    
    //The alredy selected button is stil selected when it is highlighted
    [self.wardrobeType setBackgroundImage:[UIImage imageNamed:@"segmentActive"]
                                       forState:UIControlStateSelected
                                     barMetrics:UIBarMetricsDefault];
    [self.wardrobeType setBackgroundImage:[UIImage imageNamed:@"segmentActive"] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:@"Montserrat-Regular" size:13], NSFontAttributeName,
                                [UIColor grayColor], NSForegroundColorAttributeName, nil];
    
    [self.wardrobeType setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:0.0 blue:102.0/256 alpha:1]} forState:UIControlStateSelected];
    
  //  [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor]} forState:UIControlStateNormal];
   }

@end
