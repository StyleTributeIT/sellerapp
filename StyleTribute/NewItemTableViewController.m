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
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "SingleUnitTableViewCell.h"
#import "MessageTableViewCell.h"
#import "DetailsTableViewCell.h"
#import "GuidViewController.h"
#import "ChooseCategoryController.h"
#import "ShoesSizeTableViewCell.h"
#import "SharingTableViewCell.h"
#import "UIImage+FixOrientation.h"
#import "ChooseBrandController.h"
#import "BagSizeTableViewCell.h"
#import "PriceEditController.h"
#import "PhotosTableViewCell.h"
#import "PriceTableViewCell.h"
#import "BrandTableViewCell.h"
#import "TutorialController.h"
#import "WardrobeController.h"
#import "XCDFormInputAccessoryView.h"
#import "Photo.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

typedef void(^ImageLoadBlock)(int);

@interface NewItemTableViewController ()< UIActionSheetDelegate, PhotoCellDelegate, SharingTableViewCellDelegate, GuidViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property BOOL isTutorialPresented;
@property BOOL isInitialized;
@property BOOL isProductUpdated;
@property BOOL hideSkipInGuide;
@property UIPickerView* picker;
@property Photo* lastPhoto;
@property (copy) ImageLoadBlock imgLoadBlock;
@property NSUInteger selectedImageIndex;
@property UIImage *imagedata;
@property UIActionSheet* photoActionsSheet;
@property Product *productCopy;
@property Product *originalCopy;
@property NSMutableArray* photosToDelete;
@property NSInteger *productid;
@property XCDFormInputAccessoryView* inputAccessoryView;
@end

int sectionOffset = 0;


@implementation NewItemTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isInitialized = NO;
    self.hideSkipInGuide = NO;
    self.isTutorialPresented = NO;
    self.photosToDelete = [NSMutableArray new];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
    //self.productCopy = [self.curProduct copy];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationItem.leftItemsSupplementBackButton = YES;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIImage *buttonImage = [UIImage imageNamed:@"backBtn"];
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aButton setImage:buttonImage forState:UIControlStateNormal];
    aButton.frame = CGRectMake(0.0,0.0,14,23);
    [aButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:aButton];
    self.navigationItem.leftBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
    self.inputAccessoryView = [[XCDFormInputAccessoryView alloc] initWithTarget:self hideNavButtons:YES doneAction:@selector(inputDone)];
    
    self.curProduct = [DataCache getSelectedItem];
    if(self.curProduct == nil) {
        self.curProduct = [Product new];
        self.productCopy = self.curProduct;
        self.originalCopy = [self.curProduct copy];
        [DataCache setSelectedItem:self.curProduct];
        [DataCache sharedInstance].isEditingItem = NO;
    } else
    {
        self.originalCopy = [self.curProduct copy];
    }
    for (int i = 0; i < self.curProduct.category.imageTypes.count; ++i) {
        ImageType* curImgType = [self.curProduct.category.imageTypes objectAtIndex:i];
        curImgType.state = ImageStateNormal;
    }
}

-(void)inputDone {
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated
    {
        sectionOffset = 0;
        [super viewWillAppear:animated];
//        self.curProduct = [DataCache getSelectedItem];
//        if(self.curProduct == nil) {
//            self.curProduct = [Product new];
//            self.productCopy = self.curProduct;
//            self.originalCopy = [self.productCopy copy];
//            [DataCache setSelectedItem:self.curProduct];
//            [DataCache sharedInstance].isEditingItem = NO;
//        }
        STCategory *category = self.curProduct.category;
        NSString* firstSize = [category.sizeFields firstObject];
        if ([firstSize isEqualToString:@"kidzsize"] || [firstSize isEqualToString:@"kidzshoes"])
        {
            dispatch_group_t group = dispatch_group_create();
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
            dispatch_group_enter(group);
            [[ApiRequester sharedInstance] getSizeValues:firstSize success:^(NSArray *sizes) {
                [DataCache sharedInstance].kidzSizes = sizes;
                dispatch_group_leave(group);
            } failure:^(NSString *error) {
                dispatch_group_leave(group);
            }];
            dispatch_group_notify(group, queue, ^{
                [[ApiRequester sharedInstance] getProducts:^(NSArray *products) {
                    [self.tableView reloadData];
                    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                } failure:^(NSString *error) {
                    [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
                    [GlobalHelper showMessage:error withTitle:@"error"];
                }];
            });
        } else
        {
            if(!self.isEditingItem && self.curProduct.category.name.length == 0) {
                [self performSegueWithIdentifier:@"chooseTopCategorySegue" sender:self];
            } else
            {
                self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
                self.navigationItem.title = self.curProduct.name;
            }
            
            [self.tableView reloadData];
        }
        
        
    }

    -(void)viewDidAppear:(BOOL)animated {
        [super viewDidAppear:animated];
        self.hideSkipInGuide = NO;
        if (!self.isInitialized)
        {
        }
        self.isInitialized = YES;
    }

-(BOOL) containsSelfClass:(NSMutableArray*)controllers
{
    BOOL result = false;
    for (UIViewController *vc in controllers) {
        if ([vc isKindOfClass:[self class]])
        {
            result = YES;
            break;
        }
    }
    return result;
}

    -(IBAction)cancel:(id)sender {
        sectionOffset = 0;
        if (self.isEditingItem)
            [self dismissViewControllerAnimated:true completion:nil];
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

- (IBAction)done:(id)sender {
    STCategory *category = self.curProduct.category;
    NSString* firstSize = [category.sizeFields firstObject];
    if ([firstSize isEqualToString:@"kidzsize"] || [firstSize isEqualToString:@"kidzshoes"])
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        SingleUnitTableViewCell * cell = (SingleUnitTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        self.curProduct.kidzsize = [NSString stringWithFormat:@"%lu",(unsigned long)cell.selectedUnit.identifier];
    }
    else if([firstSize isEqualToString:@"size"]) {
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
        if (cell.bagWidth.text.length != 0)
        {
            self.curProduct.dimensions = @[cell.bagWidth.text, cell.bagHeight.text, cell.bagDepth.text];
        }
    }
//    if ([self.originalCopy isEqual:self.curProduct ])
//    {
//        [self dismissViewControllerAnimated:true completion:nil];
//        return;
//    }
    self.productid = self.curProduct.identifier;
    [self saveProduct:self.curProduct];

}

-(void)saveProduct:(BOOL)pushToServer
{
    {
        
        
        bool product_valid = [self productIsValid];
        bool images_filled = [self imagesAreFilled];
        
        if (images_filled == false && pushToServer){
            [GlobalHelper showMessage:@"Please add all required images." withTitle:@"error"];
            return;
        }
        if (!product_valid && pushToServer)
        {
            [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
            return;
        }
        if (pushToServer)
        {
            [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        
            if(self.isEditingItem && [self.curProduct.processStatus isEqualToString:@"incomplete"]) {
                self.curProduct.processStatus = @"in_review_add";
            }
        }
        if (!pushToServer)
        {
            return;
        }
        [[ApiRequester sharedInstance] setProduct:self.curProduct success:^(Product* product){
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            if (self.isEditingItem)
            {
                NSMutableArray *tempImages = [[NSMutableArray alloc] init];
                int count = (int) product.photos.count;
                NSLog(@"There are %d photos now", count);
                for (int i = 0; i < count; i++) {
                    Photo *ph = [product.photos objectAtIndex:i];
                    if (![ph isKindOfClass:[NSNull class]])
                        [tempImages addObject:ph];
                }
                product.photos = [[NSArray arrayWithArray:tempImages] mutableCopy];
            }
            NSArray* oldPhotos = [NSArray arrayWithArray:product.photos];
            NSArray* oldImageTypes = product.category.imageTypes;
            product.photos = self.curProduct.photos;
            self.curProduct = product;
            
            for (int i = 0; i < product.category.imageTypes.count; ++i) {
                if(i < oldPhotos.count){
                    Photo* pOld = [oldPhotos objectAtIndex:i];
                    Photo* pNew = [self.curProduct.photos objectAtIndex:i];
                    
                    if(![pOld isKindOfClass:[NSNull class]] && ![pNew isKindOfClass:[NSNull class]]) {
                        pNew.imageUrl = pOld.imageUrl;
                        pNew.identifier = pOld.identifier;
                    }
                }
            }
            
            dispatch_group_t group = dispatch_group_create();
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            MRProgressOverlayView * progressView =[MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Uploading images" mode:MRProgressOverlayViewModeDeterminateCircular animated:YES];
            
            if(self.curProduct.photos != nil)// && self.curProduct.category != nil)
            {
                NSLog(@"%ld",self.curProduct.identifier);
                __block Product *cur_product = self.curProduct;
                //__block ImageLoadBlock *img_load_block = self.imgLoadBlock;
                __block NSMutableArray *photos_to_delete = self.photosToDelete;
                NSInteger count = MAX(self.curProduct.photos.count, oldPhotos.count);
                self.imgLoadBlock = ^(int i){
                    
                    if(i >= count)
                        return;
                    
                    
                    Photo* photo = (i < _curProduct.photos.count ? [cur_product.photos objectAtIndex:i] : nil);
                    
                    if(i < self.curProduct.category.imageTypes.count) {
                        ImageType* imageType = [/*self.curProduct.category.imageTypes*/ oldImageTypes objectAtIndex:i];
                        
                        // If we have new or modified images, then we should upload them
                        if(photo != nil && [photo isKindOfClass:[Photo class]] && imageType.state == ImageStateNew) {
                            dispatch_group_enter(group);
                            [progressView setTitleLabelText:[NSString stringWithFormat:@"Uploading image %d/%zd", i + 1, cur_product.photos.count]];
                            [[ApiRequester sharedInstance] uploadImage:photo.image ofType:imageType.type toProduct:self.productid success:^{
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
                            if(oldPhotos.count > i){
                                Photo* oldPhoto = [oldPhotos objectAtIndex:i];
                                
                                if (cur_product && oldPhoto)
                                {
                                    if (![cur_product isEqual:[NSNull null]] && ![oldPhoto isEqual:[NSNull null]])
                                    {
                                        [[ApiRequester sharedInstance] deleteImage:oldPhoto.identifier fromProduct:cur_product.identifier success:^{
                                            self.imgLoadBlock(i);
                                            dispatch_group_leave(group);
                                        } failure:^(NSString *error) {
                                            self.imgLoadBlock(i);
                                            dispatch_group_leave(group);
                                        }];
                                    }
                                }
                            }
                        } else if(imageType.state == ImageStateDeleted) {
                            dispatch_group_enter(group);
                            imageType.state = ImageStateNormal;
                            [progressView setTitleLabelText:[NSString stringWithFormat:@"Deleting image %d/%zd", i + 1, cur_product.photos.count]];
                            [progressView setProgress:1.0f animated:YES];
                            [[ApiRequester sharedInstance] deleteImage:photo.identifier fromProduct:cur_product.identifier success:^{
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
                            Photo* toDelete = [photos_to_delete firstObject];
                            [photos_to_delete removeObject:toDelete];
                            dispatch_group_enter(group);
                            [[ApiRequester sharedInstance] deleteImage:toDelete.identifier fromProduct:cur_product.identifier success:^{
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
                            [progressView setTitleLabelText:[NSString stringWithFormat:@"Uploading image %d/%zd", i + 1, cur_product.photos.count]];
                            dispatch_group_enter(group);
                            [[ApiRequester sharedInstance] uploadImage:photo.image ofType:@"custom" toProduct:self.productid success:^{
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
                    /*  MainTabBarController* tabController = (MainTabBarController*)self.tabBarController;
                     WardrobeController* wc = (WardrobeController*)[[tabController.viewControllers objectAtIndex:0] visibleViewController];
                     
                     if(!self.isEditing) {
                     [wc addNewProduct:self.curProduct];
                     } else {
                     [wc updateProductsList];
                     }
                     */
                    for (int i = 0; i < self.curProduct.category.imageTypes.count; ++i) {
                        //Photo* curPhoto = [self.curProduct.photos objectAtIndex:i];
                        [self.curProduct.category.imageTypes objectAtIndex:i];
                        //[self.curProduct.category.imageTypes removeAllObject];
                    }
                    //self.curProduct.category.imageTypes = nil;
                    self.curProduct = nil;
                    self.isEditingItem = NO;
                    //  [tabController setSelectedIndex:0];
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

#pragma mark Custom delegates

-(void)shareFB{
    Product *p = [DataCache getSelectedItem];
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:p.url];
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
}

-(void)shareTwitt:(UIViewController*)vc
{
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)shareUIActivity:(UIViewController*)vc
{
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Table view data source


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        int rowHeight = 50;
        if (((self.curProduct.processComment == nil || self.curProduct.processComment.length == 0) && ![self.curProduct.processStatus isEqualToString:@"selling"]) || indexPath.row == 1)
            rowHeight = 180;
        else
        if ([self.curProduct.processStatus isEqualToString:@"selling"] && indexPath.row == 0)
            rowHeight = 88;
        return rowHeight;
    }
    return 50;
}
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger initialSection = 4;
    STCategory *category = self.curProduct.category;
    NSString* firstSize = [category.sizeFields firstObject];
    sectionOffset = 0;
    if([firstSize containsString:@"size"] || [firstSize isEqualToString:@"kidzshoes"]) {
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


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.frame), section==0?0.1:50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, 200, 25)];
    if (section == 1)
        label.text = @"DETAILS";
    else
    if (section == 2-sectionOffset)
        label.text  = @"SIZE";
    else
    if (section == 3 - sectionOffset)
        label.text = @"BRAND";
    else
    label.text = @"";
    label.font = [UIFont fontWithName:@"Helvetica Neue" size:12];
    [label setTextColor:[UIColor colorWithRed:162.f/255 green:162.f/255 blue:162.f/255 alpha:1.0f]];
    [view addSubview: label];
    return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
    {
        int countOfCells = 1;
        if (self.curProduct.processComment != nil && self.curProduct.processComment.length > 0)
            countOfCells = 2;   // message and photos
        if ([self.curProduct.processStatus isEqualToString:@"selling"])
            countOfCells = 2;
        return countOfCells;
    }
    if (section == 1)
    {
        return 2;
    }
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([[tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[PriceTableViewCell class]])
    {
        [DataCache sharedInstance].isEditingItem = self.isEditingItem;
        DataCache *dc = [DataCache sharedInstance];
        
        if (self.isEditingItem || dc.isEditingItem)
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
        if (indexPath.row == 0 && [self.curProduct.processStatus isEqualToString:@"selling"])
        {
            return [self setupSharingCell:indexPath];
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
    if (indexPath.section == 3 - sectionOffset)
    {
        return [self setupBrandCell:indexPath];
    }
    if (indexPath.section == 2)
    {
        STCategory *category = self.curProduct.category;
        if (self.isEditingItem == true){
            if (self.curProduct.size != nil){
                return [self setupClothingSizeCell:indexPath forKey:@"size"];
            }
            else if (_curProduct.shoeSize != nil)
            {
                return [self setupShoesSizeCell:indexPath];
            }
            else if (self.curProduct.dimensions != nil)
            {
                return [self setupBagsSizeCell:indexPath];
            }
            else{
                NSString* firstSize = [category.sizeFields firstObject];
                if ([firstSize isEqualToString:@"kidzsize"] || [firstSize isEqualToString:@"kidzshoes"])
                {
                    return [self setupKidzSizeCell:indexPath];
                }
                else if([firstSize isEqualToString:@"size"]) {
                    return [self setupClothingSizeCell:indexPath forKey:@"size"];
                } else if([firstSize isEqualToString:@"shoesize"]) {
                    return [self setupShoesSizeCell:indexPath];
                } else if([firstSize isEqualToString:@"dimensions"]) {
                    return [self setupBagsSizeCell:indexPath];
                }
            }
        }
        else{
            NSString* firstSize = [category.sizeFields firstObject];
            if ([firstSize isEqualToString:@"kidzsize"] || [firstSize isEqualToString:@"kidzshoes"])
            {
                return [self setupKidzSizeCell:indexPath];
            } else
            if([firstSize isEqualToString:@"size"]) {
                return [self setupClothingSizeCell:indexPath forKey:@"size"];
            } else if([firstSize isEqualToString:@"shoesize"]) {
                return [self setupShoesSizeCell:indexPath];
            } else if([firstSize isEqualToString:@"dimensions"]) {
                return [self setupBagsSizeCell:indexPath];
            }
        }
    }
    
   
    return [self setupShoesSizeCell:indexPath];
}

-(void)addBordersForCell:(UITableViewCell*)cell addBottomBorder:(BOOL)addBottom
{
    UIView *toplineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                   1.0f,
                                                                   cell.frame.size.width, 0.2f)];
    toplineView.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f];
    [cell.contentView addSubview:toplineView];
    if (!addBottom)
        return;
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                cell.contentView.frame.size.height - 0.5f,
                                                                cell.frame.size.width, 0.2f)];
    
    lineView.backgroundColor = [UIColor colorWithRed:219/255.f green:219/255.f blue:219/255.f alpha:1.0f];
    [cell.contentView addSubview:lineView];
}

-(UITableViewCell*)setupSharingCell:(NSIndexPath*)indexPath
{
    SharingTableViewCell *cell = (SharingTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"sharingCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self addBordersForCell:cell addBottomBorder:NO];
    cell.delegate = self;
    return cell;
}

-(UITableViewCell*)setupMessageCell:(NSIndexPath*)indexPath
{
    MessageTableViewCell *cell = (MessageTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
    cell.messageLabel.text = self.curProduct.processComment;
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
 //   [self addBordersForCell:cell addBottomBorder:YES];
    return cell;
}
  
-(UITableViewCell*)setupBrandCell:(NSIndexPath*)indexPath
{
    BrandTableViewCell *cell = (BrandTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"brandCell" forIndexPath:indexPath];
    if (self.curProduct.other_designer != nil)
    {
        cell.brandTitle.text = self.curProduct.other_designer.name;
    } else {
        cell.brandTitle.text = self.curProduct.designer.name;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self addBordersForCell:cell addBottomBorder:YES];
    return cell;
}

-(UITableViewCell*)setupKidzSizeCell:(NSIndexPath*)indexPath
{
    SingleUnitTableViewCell *cell = (SingleUnitTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"singleSizeCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self addBordersForCell:cell addBottomBorder:YES];
    NamedItem *item = nil;
    for (NamedItem *dc in [DataCache sharedInstance].kidzSizes) {
        if ([[[dc valueForKey:@"identifier"] stringValue] isEqualToString:self.curProduct.kidzsize])
        {
            item = dc;
        }
    }
    cell.unitField.text = item.name;
    cell.selectedUnit = item;
    return cell;
}

-(UITableViewCell*)setupClothingSizeCell:(NSIndexPath*)indexPath forKey:(NSString*)key
{
    ClothingSizeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"clothingSizeCell" forIndexPath:indexPath];
    cell.sizesKey = key;
    [cell setup];
    NamedItem *item = nil;
    NSArray* sizes = nil;
    if ([key isEqualToString:@"kidzsize"] || [key isEqualToString:@"kidzshoes"])
    {
        sizes = [DataCache sharedInstance].kidzSizes;
    } else {
        sizes = [[[[DataCache sharedInstance].units linq_where:^BOOL(NSString* unit, id value) {
            return [unit isEqualToString:self.curProduct.unit];
        }] allValues] firstObject];
    }
    for (NamedItem *dc in sizes) {
        if ([[dc valueForKey:@"name"] isEqualToString:self.curProduct.size])
        {
            item = dc;
        }
    }
    cell.selectedSize = item;
    cell.cloathUnits.text = self.curProduct.unit;
    cell.cloathSize.text = self.curProduct.size;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self addBordersForCell:cell addBottomBorder:YES];
    
  //  cell.separatorInset = UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, cell.bounds.size.width);
    return cell;
}
    
-(UITableViewCell*)setupShoesSizeCell:(NSIndexPath*)indexPath
    {
        ShoesSizeTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"shoesSizeCell" forIndexPath:indexPath];
        [cell setup];
        cell.selectedSize = self.curProduct.shoeSize;
        cell.shoeSize.text = self.curProduct.shoeSize.name;
        cell.heelHeight.text = self.curProduct.heelHeight;
        
        STCategory *st = _curProduct.category;
        NSArray *arr = st.sizeFields;
        int count = (int) [arr count];
        if (count > 1){
            [cell.heelHeight setHidden:false];
        }
        else{
            [cell.heelHeight setHidden:true];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self addBordersForCell:cell addBottomBorder:YES];
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
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setup];
        [self addBordersForCell:cell addBottomBorder:YES];
        return cell;
    }
    
-(UITableViewCell*)setupPhotosCell:(NSIndexPath*)indexPath
{
    PhotosTableViewCell *cell = (PhotosTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"photosCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setup:self.curProduct];
    cell.delegate = self;
    [self addBordersForCell:cell addBottomBorder:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGuide)];
    [cell.guideLabel addGestureRecognizer:tap];
    return cell;
}

-(void)showGuide
{
    self.hideSkipInGuide = YES;
    [self performSegueWithIdentifier:@"showGuide" sender:self];
}

-(UITableViewCell*)setupPriceCell:(NSIndexPath*)indexPath
    {
        PriceTableViewCell *cell = (PriceTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"priceCell" forIndexPath:indexPath];
        if (self.curProduct.price != 0.0f)
            cell.productPrice.text = [NSString stringWithFormat:@"S$%.2f",self.curProduct.price];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self addBordersForCell:cell addBottomBorder:YES];
        return cell;
    }

-(UITableViewCell*)setupDescriptionCell:(NSIndexPath*)indexPath
{
    DetailsTableViewCell *cell = (DetailsTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"descriptionCell" forIndexPath:indexPath];
    [self addBordersForCell:cell addBottomBorder:NO];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.detailsText.text = self.curProduct.name!=nil?self.curProduct.name:@"About your product";
    return cell;
}


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

-(void)showCamera
{
    self.isTutorialPresented = YES;
    [self presentCameraController:UIImagePickerControllerSourceTypeCamera];
}

-(IBAction)unwindToCamera:(UIStoryboardSegue*)sender
{
    
}

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
    self.productCopy = self.curProduct;
}
    
-(IBAction)cancelUnwindToAddItem:(UIStoryboardSegue*)sender {
    if([sender.sourceViewController isKindOfClass:[TopCategoriesViewController class]]) {
      //  [self cancel:nil];
    }
}
    
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self saveProduct:NO];
    if ([segue.identifier isEqualToString:@"priceConditionSegue"])
    {
        ConditionPriceViewController *vc = segue.destinationViewController;
        vc.isEditingItem = self.isEditingItem;
    }
    if ([segue.identifier isEqualToString:@"showGuide"])
    {
        GuidViewController *guide = segue.destinationViewController;
        guide.delegate = self;
        guide.hideSkipButton = self.hideSkipInGuide;
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
    [self saveProduct:NO];
    NSInteger index = (actionSheet.destructiveButtonIndex == -1 ? (buttonIndex + 1) : buttonIndex);
    switch (index) {
        case 0: {  // Delete
            Photo* photo = [self.curProduct.photos objectAtIndex:self.selectedImageIndex];
            self.lastPhoto = photo;
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
             } else*/
            {
                 
                 
                 // if we pressed on "plus", we should add photo instead of replace.
                
                Photo* photo = self.selectedImageIndex>=self.curProduct.photos.count?NULL:[self.curProduct.photos objectAtIndex:self.selectedImageIndex];
                 if (![photo isKindOfClass:[NSNull class]] || self.isTutorialPresented)
                 {
                     [self presentCameraController: UIImagePickerControllerSourceTypeCamera];
                 } else
                 {
                     [self performSegueWithIdentifier:@"showGuide" sender:self];
                 }
                 
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
            NSString *mediaType = AVMediaTypeVideo;
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
            if(authStatus == AVAuthorizationStatusAuthorized) {
                // do your logic
                NSLog(@"AVAuthorizationStatusAuthorized");
            } else if(authStatus == AVAuthorizationStatusDenied){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable camera and photos access in your Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            } else if(authStatus == AVAuthorizationStatusRestricted){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enable camera and photos access in your Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                return;
            } else if(authStatus == AVAuthorizationStatusNotDetermined){
                // not determined?!
                NSLog(@"AVAuthorizationStatusNotDetermined");
            } else {
                // impossible, unknown authorization status
            }
            
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
                [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
                    if(granted){
                        NSLog(@"Granted access to %@", mediaType);
                    } else {
                        NSLog(@"Not granted access to %@", mediaType);
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self dismissViewControllerAnimated:YES completion:^ {
                                //Add dispatch_async as i am dismissing not on the main thread due to callback
                            }];
                        });
                    }
                }];
        } else {
            NSLog(@"accessing the photo album");
            [self presentViewController:picker animated:YES completion:^{
            }];
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                if (authorizationStatus == PHAuthorizationStatusAuthorized) {
                    // Add your custom logic here
                    NSLog(@"Authorised to see photos");
                }
                else{
                    NSLog(@"NOT Authorised to see photos");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:^ {
                            //Add dispatch_async as i am dismissing not on the main thread due to callback
                        }];
                    });
                }
            }];
        }
    } else {
        NSLog(@"camera or photo library are not available on this device");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if(self.selectedImageIndex == self.curProduct.photos.count) {
        Photo* photo = [Photo new];
        [self.curProduct.photos addObject:photo];
    }
    _imagedata = info[UIImagePickerControllerOriginalImage];
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
    self.productCopy.photos = self.curProduct.photos;
    self.productCopy.category.imageTypes =self.curProduct.category.imageTypes;
    [DataCache setSelectedItem:self.curProduct];
    [self.tableView reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  //  [self.tableView reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
  //  self.curProduct.photos = self.productCopy.photos;
//    self.curProduct.category.imageTypes = self.productCopy.category.imageTypes;
}

#pragma mark UIPicker delegates

- (void)setPickerData:(NSNotification*)aNotification {
    [self.picker reloadAllComponents];
}

#pragma mark Data validation

-(BOOL)productIsValid{
    STCategory *category = self.curProduct.category;
    NSString* firstSize = [category.sizeFields firstObject];
    if (self.curProduct.name.length == 0 || self.curProduct.descriptionText.length == 0)
    {
        return NO;
    }
    if ([firstSize isEqualToString:@"kidzsize"] || [firstSize isEqualToString:@"kidzshoes"])
    {
        if (self.curProduct.kidzsize == nil)
            return NO;
    } else
    if([firstSize isEqualToString:@"size"]) {
        if (self.curProduct.size == nil)
            return NO;
    } else if([firstSize isEqualToString:@"shoesize"]) {
        if (self.curProduct.shoeSize == nil)
            return NO;
        if (self.curProduct.shoeSize.name.length == 0)
            return NO;
        
        NSArray *arr = category.sizeFields;
        int count = (int) [arr count];
        if (count > 1){
            if ([self.curProduct.heelHeight isEqualToString:@""])
                return NO;
        }

    } else if([firstSize isEqualToString:@"dimensions"]) {
        int count = (int) self.curProduct.dimensions.count;
        if (count == 0)
            return NO;
        for(int i = 0; i < count; i++)
        {
            NSString *str = [self.curProduct.dimensions objectAtIndex:i];
            if ([str isEqualToString:@""]){
                return NO;
            }
        }
    }


    return YES;
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
