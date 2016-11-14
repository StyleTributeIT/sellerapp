//
//  NewItemTableViewController.m
//  StyleTribute
//
//  Created by Mcuser on 11/7/16.
//  Copyright © 2016 Selim Mustafaev. All rights reserved.
//

#import "NewItemTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "ItemDescriptionViewController.h"
#import "ConditionTableViewController.h"
#import "TopCategoriesViewController.h"
#import "ClothingSizeTableViewCell.h"
#import "ConditionPriceViewController.h"
#import <NSArray+LinqExtensions.h>
#import <NSDictionary+LinqExtensions.h>
#import "MessageTableViewCell.h"
#import "ChooseCategoryController.h"
#import "ShoesSizeTableViewCell.h"
#import "UIImage+FixOrientation.h"
#import "ChooseBrandController.h"
#import "MainTabBarController.h"
#import "BagSizeTableViewCell.h"
#import "PriceEditController.h"
#import "PhotosTableViewCell.h"
#import "PriceTableViewCell.h"
#import "BrandTableViewCell.h"
#import "TutorialController.h"
#import "WardrobeController.h"
#import "ApiRequester.h"
#import "GlobalHelper.h"
#import <MRProgress.h>
#import "GlobalDefs.h"
#import "DataCache.h"
#import "Photo.h"

typedef void(^ImageLoadBlock)(int);

@interface NewItemTableViewController ()<UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>
@property BOOL isTutorialPresented;
@property BOOL isInitialized;
@property BOOL isProductUpdated;
@property UIPickerView* picker;
@property (copy) ImageLoadBlock imgLoadBlock;
@property NSUInteger selectedImageIndex;
@property UIActionSheet* photoActionsSheet;
@property Product *productCopy;
@property NSMutableArray* photosToDelete;
@end

int sectionOffset = 0;

@implementation NewItemTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isInitialized = NO;
    self.isTutorialPresented = NO;
    self.photosToDelete = [NSMutableArray new];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
    self.productCopy = [self.curProduct copy];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)viewWillAppear:(BOOL)animated
    {
        sectionOffset = 0;
        [super viewWillAppear:animated];
        if(self.curProduct == nil) {
            self.curProduct = [Product new];
            [DataCache setSelectedItem:self.curProduct];
            [DataCache sharedInstance].isEditingItem = NO;
        }
        self.curProduct = [DataCache getSelectedItem];
        [self.tableView reloadData];
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
        sectionOffset = 0;
        [self dismissViewControllerAnimated:true completion:nil];
    }

- (IBAction)done:(id)sender {
    {
        STCategory *category = self.curProduct.category;
        NSString* firstSize = [category.sizeFields firstObject];
        if([firstSize isEqualToString:@"size"]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            ClothingSizeTableViewCell * cell = (ClothingSizeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            self.curProduct.size = cell.selectedSize.name;
            self.curProduct.sizeId = cell.selectedSize.identifier;
            self.curProduct.unit = cell.cloathUnits.text;
        } else if([firstSize isEqualToString:@"shoesize"]) {
             NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            ShoesSizeTableViewCell * cell = (ShoesSizeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            self.curProduct.shoeSize = cell.selectedSize;
            self.curProduct.heelHeight = cell.heelHeight.text;
        } else if([firstSize isEqualToString:@"dimensions"]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
            BagSizeTableViewCell * cell = (BagSizeTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            self.curProduct.dimensions = @[cell.bagWidth.text, cell.bagHeight.text, cell.bagDepth];
        }
        
        if (![self productIsValid])
        {
            [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
            return;
        }
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        
        if(self.isEditing && [self.curProduct.processStatus isEqualToString:@"incomplete"]) {
            self.curProduct.processStatus = @"in_review_add";
        }
        
        [[ApiRequester sharedInstance] setProduct:self.curProduct success:^(Product* product){
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            //            self.curProduct.identifier = product.identifier;
            //            self.curProduct.processStatus = product.processStatus;
            NSMutableArray *tempImages = [NSMutableArray new];
            for (Photo * ph in product.photos) {
                if (![ph isKindOfClass:[NSNull class]])
                    [tempImages addObject:ph];
            }
            product.photos = [NSArray arrayWithArray:tempImages];
            NSArray* oldPhotos = [NSArray arrayWithArray:product.photos];
            NSArray* oldImageTypes = product.category.imageTypes;
            product.photos = self.curProduct.photos;
            self.curProduct = product;
            
            for (int i = 0; i < product.category.imageTypes.count; ++i) {
                Photo* pOld = [oldPhotos objectAtIndex:i];
                Photo* pNew = [self.curProduct.photos objectAtIndex:i];
                
                if(![pOld isKindOfClass:[NSNull class]] && ![pNew isKindOfClass:[NSNull class]]) {
                    pNew.imageUrl = pOld.imageUrl;
                    pNew.identifier = pOld.identifier;
                }
            }
            
            dispatch_group_t group = dispatch_group_create();
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            MRProgressOverlayView * progressView =[MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Uploading images" mode:MRProgressOverlayViewModeDeterminateCircular animated:YES];
            
            if(self.curProduct.photos != nil && self.curProduct.category != nil) {
                
                NSInteger count = MAX(self.curProduct.photos.count, oldPhotos.count);
                self.imgLoadBlock = ^(int i){
                    
                    if(i >= count)
                        return;
                    
                    Photo* photo = (i < _curProduct.photos.count ? [_curProduct.photos objectAtIndex:i] : nil);
                    
                    if(i < self.curProduct.category.imageTypes.count) {
                        Photo* oldPhoto = [oldPhotos objectAtIndex:i];
                        ImageType* imageType = [/*self.curProduct.category.imageTypes*/ oldImageTypes objectAtIndex:i];
                        
                        // If we have new or modified images, then we should upload them
                        if(photo != nil && [photo isKindOfClass:[Photo class]] && imageType.state == ImageStateNew) {
                            dispatch_group_enter(group);
                            [progressView setTitleLabelText:[NSString stringWithFormat:@"Uploading image %d/%zd", i + 1, self.curProduct.photos.count]];
                            [[ApiRequester sharedInstance] uploadImage:photo.image ofType:imageType.type toProduct:self.curProduct.identifier success:^{
                                imageType.state = ImageStateNormal;
                                self.imgLoadBlock(i + 1);
                                dispatch_group_leave(group);
                            } failure:^(NSString *error) {
                                self.imgLoadBlock(i + 1);
                                dispatch_group_leave(group);
                            } progress:^(float progress) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [progressView setProgress:progress animated:YES];
                                    NSLog(@"progress: %f", progress);
                                });
                            }];
                        } else if(photo != nil && [photo isKindOfClass:[Photo class]] && imageType.state == ImageStateModified) {
                            dispatch_group_enter(group);
                            imageType.state = ImageStateNew;
                            [[ApiRequester sharedInstance] deleteImage:oldPhoto.identifier fromProduct:self.curProduct.identifier success:^{
                                self.imgLoadBlock(i);
                                dispatch_group_leave(group);
                            } failure:^(NSString *error) {
                                self.imgLoadBlock(i);
                                dispatch_group_leave(group);
                            }];
                        } else if(imageType.state == ImageStateDeleted) {
                            dispatch_group_enter(group);
                            imageType.state = ImageStateNormal;
                            [progressView setTitleLabelText:[NSString stringWithFormat:@"Deleting image %d/%zd", i + 1, self.curProduct.photos.count]];
                            [progressView setProgress:1.0f animated:YES];
                            [[ApiRequester sharedInstance] deleteImage:photo.identifier fromProduct:self.curProduct.identifier success:^{
                                self.imgLoadBlock(i + 1);
                                dispatch_group_leave(group);
                            } failure:^(NSString *error) {
                                self.imgLoadBlock(i + 1);
                                dispatch_group_leave(group);
                            }];
                        } else {
                            self.imgLoadBlock(i + 1);
                        }
                    } else {
                        // remove images marked for deletion
                        if(self.photosToDelete.count > 0) {
                            Photo* toDelete = [self.photosToDelete firstObject];
                            [self.photosToDelete removeObject:toDelete];
                            dispatch_group_enter(group);
                            [[ApiRequester sharedInstance] deleteImage:toDelete.identifier fromProduct:self.curProduct.identifier success:^{
                                self.imgLoadBlock(i);
                                dispatch_group_leave(group);
                            } failure:^(NSString *error) {
                                self.imgLoadBlock(i);
                                dispatch_group_leave(group);
                            }];
                            return;
                        }
                        
                        // Additional images
                        if(photo != nil && photo.image != nil) {
                            [progressView setTitleLabelText:[NSString stringWithFormat:@"Uploading image %d/%zd", i + 1, self.curProduct.photos.count]];
                            dispatch_group_enter(group);
                            [[ApiRequester sharedInstance] uploadImage:photo.image ofType:@"custom" toProduct:self.curProduct.identifier success:^{
                                self.imgLoadBlock(i + 1);
                                dispatch_group_leave(group);
                            } failure:^(NSString *error) {
                                self.imgLoadBlock(i + 1);
                                dispatch_group_leave(group);
                            } progress:^(float progress) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [progressView setProgress:progress animated:YES];
                                    NSLog(@"progress: %f", progress);
                                });
                            }];
                        } else {
                            self.imgLoadBlock(i + 1);
                        }
                    }
                };
                self.imgLoadBlock(0);
            }
            
            dispatch_group_notify(group, queue, ^{
                NSLog(@"All tasks done");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    MainTabBarController* tabController = (MainTabBarController*)self.tabBarController;
                    WardrobeController* wc = (WardrobeController*)[[tabController.viewControllers objectAtIndex:0] visibleViewController];
                    
                    if(!self.isEditing) {
                        [wc addNewProduct:self.curProduct];
                    } else {
                        [wc updateProductsList];
                    }
                    
                    self.curProduct = nil;
                    self.isEditingItem = NO;
                    [tabController setSelectedIndex:0];
                    [self dismissViewControllerAnimated:true completion:nil];
                });
            });
            
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
        }];
    }
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
        if ((self.curProduct.processComment == nil || self.curProduct.processComment.length == 0) || indexPath.row == 1)
            return 140;
        return 44;
    }
    return 44;
}
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger initialSection = 4;
    STCategory *category = self.curProduct.category;
    NSString* firstSize = [category.sizeFields firstObject];
    sectionOffset = 0;
    if([firstSize isEqualToString:@"size"]) {
    } else if([firstSize isEqualToString:@"shoesize"]) {
    } else if([firstSize isEqualToString:@"dimensions"]) {
    } else {
        initialSection--;
        sectionOffset = 1;
    }
    return initialSection;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
    {
        if (section == 1)
            return @"DETAILS";
        if (section == 2-sectionOffset)
            return @"SIZE";
        if (section == 3 - sectionOffset)
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
        header.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    }
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        if (self.curProduct.processComment != nil && self.curProduct.processComment.length > 0)
            return 2;   // message and photos
        return 1;
    }
    if (section == 1)
    {
        return 2;
    }
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[PriceTableViewCell class]])
    {
        if (self.isEditingItem)
        {
            [self performSegueWithIdentifier:@"priceConditionSegue" sender:nil];
        } else
        {
            [self performSegueWithIdentifier:@"condition" sender:nil];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0 && self.curProduct.processComment != nil && self.curProduct.processComment.length > 0) {
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
        STCategory *category = self.curProduct.category;
        NSString* firstSize = [category.sizeFields firstObject];
        if([firstSize isEqualToString:@"size"]) {
            return [self setupClothingSizeCell:indexPath];
        } else if([firstSize isEqualToString:@"shoesize"]) {
            return [self setupShoesSizeCell:indexPath];
        } else if([firstSize isEqualToString:@"dimensions"]) {
            return [self setupBagsSizeCell:indexPath];
        }
        
    }
    if (indexPath.section == 3 - sectionOffset)
    {
        return [self setupBrandCell:indexPath];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    return cell;
}

-(UITableViewCell*)setupMessageCell:(NSIndexPath*)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    cell.messageLabel.text = self.curProduct.processComment;
    return cell;
}
  
-(UITableViewCell*)setupBrandCell:(NSIndexPath*)indexPath
{
    BrandTableViewCell *cell = (BrandTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"brandCell" forIndexPath:indexPath];
    cell.brandTitle.text = self.curProduct.designer.name;
    return cell;
}

-(UITableViewCell*)setupClothingSizeCell:(NSIndexPath*)indexPath
{
    ClothingSizeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"clothingSizeCell" forIndexPath:indexPath];
    [cell setup];
    NamedItem *item = nil;
    NSArray* sizes = [[[[DataCache sharedInstance].units linq_where:^BOOL(NSString* unit, id value) {
        return [unit isEqualToString:self.curProduct.unit];
    }] allValues] firstObject];
    for (NamedItem *dc in sizes) {
        if ([[dc valueForKey:@"name"] isEqualToString:self.curProduct.size])
        {
            item = dc;
        }
    }
    cell.selectedSize = item;
    cell.cloathUnits.text = self.curProduct.unit;
    cell.cloathSize.text = self.curProduct.size;
    return cell;
}
    
-(UITableViewCell*)setupShoesSizeCell:(NSIndexPath*)indexPath
    {
        ShoesSizeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"shoesSizeCell" forIndexPath:indexPath];
        [cell setup];
        cell.selectedSize = self.curProduct.shoeSize;
        cell.shoeSize.text = self.curProduct.shoeSize.name;
        cell.heelHeight.text = self.curProduct.heelHeight;
        return cell;
    }
    
    -(UITableViewCell*)setupBagsSizeCell:(NSIndexPath*)indexPath
    {
        BagSizeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"bagsSizeCell" forIndexPath:indexPath];
        if(self.curProduct.dimensions) {
            cell.bagWidth.text = [self.curProduct.dimensions objectAtIndex:0];
            cell.bagHeight.text = [self.curProduct.dimensions objectAtIndex:1];
            cell.bagDepth.text = [self.curProduct.dimensions objectAtIndex:2];
        }
        [cell setup];
        return cell;
    }
    
-(UITableViewCell*)setupPhotosCell:(NSIndexPath*)indexPath
{
    PhotosTableViewCell *cell = (PhotosTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"photosCell" forIndexPath:indexPath];
    [cell setup:self.curProduct];
    cell.delegate = self;
    return cell;
}

-(UITableViewCell*)setupPriceCell:(NSIndexPath*)indexPath
    {
        PriceTableViewCell *cell = (PriceTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"priceCell" forIndexPath:indexPath];
        if (self.curProduct.price != 0.0f)
            cell.productPrice.text = [NSString stringWithFormat:@"$%.2f",self.curProduct.price];
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

#pragma mark Self delegates

-(void)selectedImageIndex:(NSUInteger)selectedImageIndex
{
    self.selectedImageIndex = selectedImageIndex;
    if(self.selectedImageIndex == self.curProduct.photos.count) {
        [self displayActionSheet:NO];
    } else {
        if(self.selectedImageIndex >= self.curProduct.category.imageTypes.count) {
            [self displayActionSheet:YES];
        } else {
            [self displayActionSheet:NO];
        }
    }
    
    [self.photoActionsSheet showInView:self.view];
}

#pragma mark - Segues unwind handlers
    
-(IBAction)unwindToAddItem:(UIStoryboardSegue*)sender {
    if ([sender.sourceViewController isKindOfClass:[ItemDescriptionViewController class]])
    {
        self.curProduct = ((ItemDescriptionViewController*)sender.sourceViewController).selectedProduct;
    }
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
        if ([segue.identifier isEqualToString:@"priceConditionSegue"])
        {
            ConditionPriceViewController *vc = segue.destinationViewController;
            vc.isEditingItem = self.isEditingItem;
        }
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

#pragma mark - Action sheet

-(void)displayActionSheet:(BOOL)displayDestructiveButton {
    self.photoActionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:(displayDestructiveButton ? @"Delete picture" : nil) otherButtonTitles:@"Take new picture", @"Pick from gallery", nil];
    self.photoActionsSheet.delegate = self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSInteger index = (actionSheet.destructiveButtonIndex == -1 ? (buttonIndex + 1) : buttonIndex);
    switch (index) {
        case 0: {  // Delete
            Photo* photo = [self.curProduct.photos objectAtIndex:self.selectedImageIndex];
            if(self.selectedImageIndex >= self.curProduct.category.imageTypes.count) {
                [self.curProduct.photos removeObject:photo];
                if(photo.identifier != 0) {
                    [self.photosToDelete addObject:photo];
                }
            } else {
                ImageType* imgType = (ImageType*)[self.curProduct.category.imageTypes objectAtIndex:self.selectedImageIndex];
                if(imgType.state != ImageStateDeleted) {
                    if(imgType.state == ImageStateModified || (imgType.state == ImageStateNormal && ![[self.curProduct.photos objectAtIndex:self.selectedImageIndex] isKindOfClass:[NSNull class]]))
                        imgType.state = ImageStateDeleted;
                    else if(imgType.state == ImageStateNew)
                        imgType.state = ImageStateNormal;
                }
            }
            photo.image = nil;
            photo.thumbnailUrl = photo.imageUrl = @"";
            [self.tableView reloadData];
            break;
        }
        case 1: { // take new picture
            /* tutorial disabled:
             NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
             if([defs objectForKey:@"displayTutorial"] == nil) {
             [self performSegueWithIdentifier:@"tutorialSegue" sender:self];
             [defs setBool:NO forKey:@"displayTutorial"];
             self.isTutorialPresented = YES;
             } else*/ {
                 [self presentCameraController: UIImagePickerControllerSourceTypeCamera];
             }
            break;
        }
        case 2: // pick from gallery
            [self presentCameraController: UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        default:
            break;
    }
}

#pragma mark - Camera

-(void)presentCameraController:(UIImagePickerControllerSourceType)type {
    if([UIImagePickerController isSourceTypeAvailable:type]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = type;
        picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
        
        if(type == UIImagePickerControllerSourceTypeCamera) {
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            CGRect cameraViewRect = [[UIScreen mainScreen] bounds];
            if(screenSize.height/screenSize.width > 1.5) {
                cameraViewRect = CGRectMake(0, 40, screenSize.width, screenSize.width*4.0/3.0);
            }
            
            ImageType* imgType = nil;
            if(self.selectedImageIndex < self.curProduct.category.imageTypes.count) {
                imgType = [self.curProduct.category.imageTypes objectAtIndex:self.selectedImageIndex];
            }
            
            if(imgType && imgType.outline.length > 0) {
                [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:imgType.outline] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                } completed:^(UIImage *outline, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                    if(error != nil) {
                        NSLog(@"error loading outline image: %@", [error description]);
                    } else {
                        CGSize oSize = CGSizeMake(outline.size.width, outline.size.height);
                        if(outline.size.width > screenSize.width) {
                            CGFloat m = screenSize.width/outline.size.width;
                            oSize.width *= m;
                            oSize.height *= m;
                        }
                        
                        UIImageView* overlay = [[UIImageView alloc] initWithFrame:CGRectMake((cameraViewRect.size.width - oSize.width)/2, (cameraViewRect.size.height - oSize.height)/2 + cameraViewRect.origin.y, oSize.width, oSize.height)];
                        overlay.image = outline;
                        picker.cameraOverlayView = overlay;
                    }
                    
                    [self presentViewController:picker animated:YES completion:^{
                    }];
                }];
            } else {
                [self presentViewController:picker animated:YES completion:^{
                }];
            }
        } else {
            [self presentViewController:picker animated:YES completion:^{
            }];
        }
    } else {
        NSLog(@"camera or photo library are not available on this device");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    UIImage *finalImage = [chosenImage fixOrientation:chosenImage.imageOrientation];
    
    Photo* photo = [Photo new];
    photo.image = finalImage;
    
    // if we pressed on "plus", we should add photo instead of replace.
    if(self.selectedImageIndex == self.curProduct.photos.count) {
        [self.curProduct.photos addObject:photo];
    } else {
        Photo* oldPhoto = [self.curProduct.photos objectAtIndex:self.selectedImageIndex];
        [self.curProduct.photos replaceObjectAtIndex:self.selectedImageIndex withObject:photo];
        
        if(self.selectedImageIndex < self.curProduct.category.imageTypes.count) {
            ImageType* imgType = (ImageType*)[self.curProduct.category.imageTypes objectAtIndex:self.selectedImageIndex];
            imgType.state = (imgType.state == ImageStateNormal ? ImageStateNew : ImageStateModified);
            
            if(oldPhoto && ![oldPhoto isKindOfClass:[NSNull class]] && oldPhoto.imageUrl.length > 0)
                imgType.state = ImageStateModified;
        } else {
            // if we going to replace previosly uploaded photo, then add them to deletion list
            if(oldPhoto.identifier != 0) {
                [self.photosToDelete addObject:oldPhoto];
            }
        }
    }
    
    [self.tableView reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark UIPicker delegates

- (void)setPickerData:(NSNotification*)aNotification {
    [self.picker reloadAllComponents];
}

#pragma mark Data validation

-(BOOL)productIsValid{
    BOOL result = YES;
    if (self.curProduct.name.length == 0 || self.curProduct.descriptionText.length == 0)
        result = NO;
    return result;
}

-(BOOL)imagesAreFilled {
    BOOL result = YES;
    
    // TODO: check only required images
    for (int i = 0; i < self.curProduct.category.imageTypes.count; ++i) {
        Photo* curPhoto = [self.curProduct.photos objectAtIndex:i];
        ImageType* curImgType = [self.curProduct.category.imageTypes objectAtIndex:i];
        
        if(curImgType.state != ImageStateNew && curImgType.state != ImageStateModified && ([curPhoto isKindOfClass:[NSNull class]] || (curPhoto.imageUrl.length == 0 && curPhoto.image == nil)))
            result = NO;
    }
    
    return result;
}


    
@end
