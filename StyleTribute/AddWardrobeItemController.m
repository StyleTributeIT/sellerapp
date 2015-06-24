//
//  AddWardrobeItemController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalDefs.h"
#import "GlobalHelper.h"
#import "AddWardrobeItemController.h"
#import "ChooseCategoryController.h"
#import "TutorialController.h"
#import "MainTabBarController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "DataCache.h"
#import "Category.h"
#import "PhotoCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ApiRequester.h"
#import <MRProgress.h>
#import <NSArray+LinqExtensions.h>
#import "NamedItems.h"

#define PHOTOS_PER_ROW 4

@interface AddWardrobeItemController ()

@property UIPickerView* picker;
@property UIToolbar* pickerToolbar;
@property UIActionSheet* photoActionsSheet;

@property NSArray* sizes;
@property BOOL isTutorialPresented;
@property UIImageView* selectedImage;
@property NSUInteger selectedImageIndex;

@end

@implementation AddWardrobeItemController

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isTutorialPresented = NO;
    self.collectionViewHeight.constant = self.collectionView.frame.size.width/PHOTOS_PER_ROW;
    
    self.picker = [GlobalHelper createPickerForFields:@[self.conditionField, self.sizeField, self.brandField]];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    
    self.sizes = @[@"size 1", @"size 2", @"size 3", @"size 4", @"size 5"];

    self.messageLabel.text = @""; //@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";
    
    [GlobalHelper addLogoToNavBar:self.navigationItem];
    [self.messageLabel sizeToFit];
    
    self.photoActionsSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take new picture", @"Pick from gallery", nil];
    self.photoActionsSheet.delegate = self;
    
    self.textViewBackground.image = [[UIImage imageNamed:@"Edit"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.accessibilityIdentifier = @"Photos collection";
    self.collectionView.accessibilityLabel = @"Photos collection";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
    
    if([DataCache sharedInstance].designers == nil) {
        [[ApiRequester sharedInstance] getDesigners:^(NSArray *designers) {
            [MRProgressOverlayView dismissOverlayForView:self.picker animated:YES];
            [DataCache sharedInstance].designers = designers;
            [self.picker reloadAllComponents];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:self.picker animated:YES];
        }];
    }
    
    if([DataCache sharedInstance].conditions == nil) {
        [[ApiRequester sharedInstance] getConditions:^(NSArray *conditions) {
            [MRProgressOverlayView dismissOverlayForView:self.picker animated:YES];
            [DataCache sharedInstance].conditions = conditions;
            [self.picker reloadAllComponents];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:self.picker animated:YES];
        }];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.curProduct == nil) {
        self.curProduct = [Product new];
        self.categoryField.text = @"";
        self.brandField.text = @"";
        self.sizeField.text = @"";
        self.conditionField.text = @"";
        self.descriptionView.text = @"";
    } else {
        // TODO: fill in all fields
        self.categoryField.text = self.curProduct.category.name;
        self.brandField.text = self.curProduct.designer.name;
    }
    
    [self updatePhotosCollection];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.isTutorialPresented) {
        [self presentCameraController: UIImagePickerControllerSourceTypeCamera];
        self.isTutorialPresented = NO;
    }
}

- (void)setPickerData:(NSNotification*)aNotification {
    if(self.activeField == self.conditionField || self.activeField == self.sizeField || self.activeField == self.brandField) {
        [self.picker reloadAllComponents];
        
        NSUInteger index = 0;
        if(self.activeField == self.brandField) {
            NamedItem* curDesigner = [[[DataCache sharedInstance].designers linq_where:^BOOL(NamedItem* item) {
                return [item.name isEqualToString:((UITextField*)self.activeField).text];
            }] firstObject];
            index = [[DataCache sharedInstance].designers indexOfObject:curDesigner];
        } else if(self.activeField == self.conditionField) {
            NamedItem* curCondition = [[[DataCache sharedInstance].conditions linq_where:^BOOL(NamedItem* item) {
                return [item.name isEqualToString:((UITextField*)self.conditionField).text];
            }] firstObject];
            index = [[DataCache sharedInstance].conditions indexOfObject:curCondition];
        } else {
            index = [[self getCurrentDatasource] indexOfObject:((UITextField*)self.activeField).text];
        }
        
        if(index == NSNotFound) {
            index = 0;
        }
        
        [self.picker selectRow:index inComponent:0 animated:NO];
    }
    
    if((self.activeField == self.brandField && [DataCache sharedInstance].designers == nil) ||
       (self.activeField == self.conditionField && [DataCache sharedInstance].conditions == nil)) {
        if([MRProgressOverlayView overlayForView:self.picker] == nil) {
            [MRProgressOverlayView showOverlayAddedTo:self.picker  title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:NO];
        }
    } else {
        if([MRProgressOverlayView overlayForView:self.picker] != nil) {
            [MRProgressOverlayView dismissOverlayForView:self.picker animated:NO];
        }
    }
}

#pragma mark - UIPickerView

-(NSArray*)getCurrentDatasource {
    if(self.activeField == self.conditionField) {
        return [DataCache sharedInstance].conditions;
    } else if(self.activeField == self.sizeField) {
        return self.sizes;
    } else if(self.activeField == self.brandField) {
        return [DataCache sharedInstance].designers;
    }
    
    return nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self getCurrentDatasource].count;
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if(self.activeField == self.brandField || self.activeField == self.conditionField) {
        NamedItem* item = [[self getCurrentDatasource] objectAtIndex:row];
        return item.name;
    } else {
        return [[self getCurrentDatasource] objectAtIndex:row];
    }
}

-(void)inputDone {
    NSInteger index = [self.picker selectedRowInComponent:0];
    if(self.activeField == self.sizeField) {
        self.sizeField.text = [self.sizes objectAtIndex:index];
    } else if(self.activeField == self.brandField) {
        NamedItem* designer = [[DataCache sharedInstance].designers objectAtIndex:index];
        self.curProduct.designer = designer;
        self.brandField.text = designer.name;
    } else if(self.activeField == self.conditionField) {
        NamedItem* condition = [[DataCache sharedInstance].conditions objectAtIndex:index];
        self.curProduct.condition = condition;
        self.conditionField.text = condition.name;
    }
    
    [self.activeField resignFirstResponder];
}

#pragma mark - Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0: { // take new picture
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            if([defs objectForKey:@"displayTutorial"] == nil) {
                [self performSegueWithIdentifier:@"tutorialSegue" sender:self];
                [defs setBool:NO forKey:@"displayTutorial"];
                self.isTutorialPresented = YES;
            } else {
                [self presentCameraController: UIImagePickerControllerSourceTypeCamera];
            }
            break;
        }
        case 1: // pick from gallery
            [self presentCameraController: UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        default:
            break;
    }
}

#pragma mark - Segues unwind handlers

-(IBAction)unwindToAddItem:(UIStoryboardSegue*)sender {
    if([sender.sourceViewController isKindOfClass:[ChooseCategoryController class]]) {
        ChooseCategoryController* ccController = sender.sourceViewController;
        self.categoryField.text = ccController.selectedCategory.name;
        self.curProduct.category = ccController.selectedCategory;
        [self updatePhotosCollection];
    } else if([sender.sourceViewController isKindOfClass:[TutorialController class]]) {
    }
    
    NSLog(@"unwindToAddItem");
}

-(IBAction)cancelUnwindToAddItem:(UIStoryboardSegue*)sender {
    //    UIViewController *sourceViewController = sender.sourceViewController;
    NSLog(@"cancelUnwindToWardrobeItems");
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == self.categoryField) {
        [self performSegueWithIdentifier:@"chooseCategorySegue" sender:self];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    [self setPickerData:nil];
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
            
            ImageType* imgType = [self.curProduct.category.imageTypes objectAtIndex:self.selectedImageIndex];
            
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
                    
                    [self presentViewController:picker animated:YES completion:^{
                    }];
                }
            }];
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
    self.selectedImage.image = chosenImage;
//    NSData *imageData = UIImageJPEGRepresentation(chosenImage, 0.9);
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Actions

-(IBAction)cancel:(id)sender {
    NSLog(@"cancel");
    
    self.curProduct = nil;
    
    MainTabBarController* tabController = (MainTabBarController*)self.tabBarController;
    [tabController selectPreviousTab];
}

-(IBAction)done:(id)sender {
    NSLog(@"done");
    
    if(self.categoryField.text.length == 0 ||
       self.descriptionView.text.length == 0 ||
       self.brandField.text.length == 0 ||
       self.sizeField.text.length == 0 ||
       self.conditionField.text.length == 0) {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
        return;
    } else {
        self.curProduct = nil;
        MainTabBarController* tabController = (MainTabBarController*)self.tabBarController;
        [tabController selectPreviousTab];
    }
}

#pragma mark - Photo collection

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.curProduct.category.imageTypes.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    ImageType* imgType = [self.curProduct.category.imageTypes objectAtIndex:indexPath.row];
    newCell.photoTypeLabel.text = imgType.name;
    [newCell.photoView sd_setImageWithURL:[NSURL URLWithString:imgType.preview] placeholderImage:[UIImage imageNamed:@"stub"]];
    newCell.photoView.tag = indexPath.row;
    newCell.accessibilityLabel = [NSString stringWithFormat:@"Photo cell %td", indexPath.row];
    return newCell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemSize = collectionView.frame.size.width/PHOTOS_PER_ROW;
    return CGSizeMake(itemSize, itemSize);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell* cell = (PhotoCell*)[collectionView cellForItemAtIndexPath:indexPath];
    self.selectedImage = cell.photoView;
    self.selectedImageIndex = indexPath.row;
    [self.photoActionsSheet showInView:self.view];
    return NO;
}

-(void)updatePhotosCollection {
    NSUInteger rowsCount = 0;
    if(self.curProduct != nil && self.curProduct.category != nil) {
        rowsCount = self.curProduct.category.imageTypes.count/PHOTOS_PER_ROW + ((self.curProduct.category.imageTypes.count % PHOTOS_PER_ROW) == 0 ? 0 : 1);
    }
    self.collectionViewHeight.constant = self.collectionView.frame.size.width*rowsCount/PHOTOS_PER_ROW;
    [self.collectionView reloadData];
}

@end
