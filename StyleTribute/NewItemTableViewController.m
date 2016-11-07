//
//  NewItemTableViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "NewItemTableViewController.h"
#import "GlobalDefs.h"
#import "GlobalHelper.h"
#import "ChooseCategoryController.h"
#import "TutorialController.h"
#import "MainTabBarController.h"
#import "TopCategoriesViewController.h"
#import "WardrobeController.h"
#import "ChooseBrandController.h"
#import "PriceEditController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "DataCache.h"
#import "PhotosTableViewCell.h"
#import "PriceTableViewCell.h"
#import "BrandTableViewCell.h"
#import "ConditionTableViewController.h"

@interface NewItemTableViewController ()
@property BOOL isTutorialPresented;
    @property BOOL isInitialized;
    @property BOOL isProductUpdated;
@end

@implementation NewItemTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isInitialized = NO;
    self.isTutorialPresented = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
        if(self.curProduct == nil) {
            self.curProduct = [Product new];
        }
        if(!self.isEditing && self.curProduct.category.name.length == 0) {
            [self performSegueWithIdentifier:@"chooseTopCategorySegue" sender:self];
        }
    }
    
    -(void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
        if(self.isTutorialPresented) {
           // [self presentCameraController: UIImagePickerControllerSourceTypeCamera];
            self.isTutorialPresented = NO;
        }
        
        if(self.isInitialized) {
        
        }
        self.isInitialized = YES;
    }
    
    -(IBAction)cancel:(id)sender {
        NSLog(@"cancel");
        [self dismissViewControllerAnimated:true completion:nil];
    }
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

    
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
            return 136;
        return 44;
    }
    return 44;
}
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
    {
        if (section == 1)
            return @"DETAILS";
        if (section == 2)
            return @"SIZE";
        if (section == 3)
            return @"BRAND";
        return @"";
    }
    
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
    {
       if (section == 0)
            return 0.1;
        return 50;
    }

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
    {
            view.tintColor = [UIColor whiteColor];
            UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
            [header.textLabel setTextColor:[UIColor colorWithRed:162.f/255 green:162.f/255 blue:162.f/255 alpha:1.0f]];
    }
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 2;   // message and photos
    if (section == 1)
    {
        return 2;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0) {
            return [self setupMessageCell:indexPath];
        }
        return [self setupPhotosCell:indexPath];
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
            return [self setupDescriptionCell:indexPath];
        if (indexPath.row == 1)
        return [self setupPriceCell:indexPath];
    }
    if (indexPath.section == 2)
    {
        return [self setupShoesSizeCell:indexPath];
    }
    if (indexPath.section == 3)
    {
        return [self setupBrandCell:indexPath];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    return cell;
}

-(UITableViewCell*)setupMessageCell:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    return cell;
}
  
-(UITableViewCell*)setupBrandCell:(NSIndexPath*)indexPath
{
    BrandTableViewCell *cell = (BrandTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"brandCell" forIndexPath:indexPath];
    cell.brandTitle.text = self.curProduct.designer.name;
    return cell;
}

-(UITableViewCell*)setupShoesSizeCell:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"clothingSizeCell" forIndexPath:indexPath];
    return cell;
}
    
-(UITableViewCell*)setupPhotosCell:(NSIndexPath*)indexPath
{
    PhotosTableViewCell *cell = (PhotosTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"photosCell" forIndexPath:indexPath];
    [cell setup:self.curProduct];
    return cell;
}

-(UITableViewCell*)setupPriceCell:(NSIndexPath*)indexPath
    {
        PriceTableViewCell *cell = (PriceTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"priceCell" forIndexPath:indexPath];
        if (self.curProduct.price != 0.0f)
            cell.productPrice.text = [NSString stringWithFormat:@"$%f",self.curProduct.price];
        return cell;
    }

-(UITableViewCell*)setupDescriptionCell:(NSIndexPath*)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"descriptionCell" forIndexPath:indexPath];
    return cell;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - Segues unwind handlers
    
-(IBAction)unwindToAddItem:(UIStoryboardSegue*)sender {
    if ([sender.sourceViewController isKindOfClass:[PriceEditController class]])
    {
        self.curProduct.price = ((PriceEditController*)sender.sourceViewController).product.price;
        [self.tableView reloadData];
    }
    if([sender.sourceViewController isKindOfClass:[TopCategoriesViewController class]]) {
        TopCategoriesViewController* ccController = sender.sourceViewController;
        self.curProduct.category = ccController.selectedCategory;
        
        self.curProduct.photos = [NSMutableArray arrayWithCapacity:self.curProduct.category.imageTypes.count];
        for(int i = 0; i < self.curProduct.category.imageTypes.count; ++i) {
            [self.curProduct.photos addObject:[NSNull null]];
        }
      //  [self displaySizeFieldsByCategory:self.curProduct.category];
    } else if([sender.sourceViewController isKindOfClass:[TutorialController class]]) {
    } else if([sender.sourceViewController isKindOfClass:[ChooseBrandController class]]) {
        //self.brandField.text = self.curProduct.designer.name;
    }
    
    NSLog(@"unwindToAddItem");
}
    
-(IBAction)cancelUnwindToAddItem:(UIStoryboardSegue*)sender {
    //    UIViewController *sourceViewController = sender.sourceViewController;
    NSLog(@"cancelUnwindToWardrobeItems");
    
    if([sender.sourceViewController isKindOfClass:[TopCategoriesViewController class]]) {
      //  [self cancel:nil];
    }
}
    
    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
    {
        if ([segue.identifier isEqualToString:@"conditionSegue"])
        {
            ConditionTableViewController *vc = segue.destinationViewController;
            vc.product = self.curProduct;
        }
        if([segue.identifier isEqualToString:@"priceSegue"]) {
            PriceEditController* priceController = segue.destinationViewController;
            priceController.product = self.curProduct;
        } else if([segue.identifier isEqualToString:@"ChooseBrandSegue2"]) {
            ChooseBrandController* brandController = segue.destinationViewController;
            brandController.product = self.curProduct;
        } else if ([segue.identifier isEqualToString:@"chooseTopCategorySegue"])
        {
            TopCategoriesViewController *categories = segue.destinationViewController;
            categories.product = self.curProduct;
        }
    }

@end
