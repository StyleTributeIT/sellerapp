//
//  AddWardrobeItemController.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "AddWardrobeItemController.h"
#import "ChooseCategoryController.h"
#import "TutorialController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Category.h"
#import "PhotoCell.h"
#import "NamedItems.h"
#import "Photo.h"
#import "TopCategoriesViewController.h"
#import "WardrobeController.h"
#import "PriceEditController.h"
#import "UIFloatLabelTextField.h"
#import "UIImage+FixOrientation.h"
#import "ChooseBrandController.h"
#import "UITextView+Placeholder.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#define PHOTOS_PER_ROW 3.5f

typedef void(^ImageLoadBlock)(int);

@interface AddWardrobeItemController ()

@property UIPickerView* picker;
@property UIToolbar* pickerToolbar;
@property UIActionSheet* photoActionsSheet;

@property NSArray* sizes;
@property BOOL isTutorialPresented;
@property UIImageView* selectedImage;
@property NSUInteger selectedImageIndex;
@property NSMutableArray* photosToDelete;
@property BOOL isInitialized;
@property BOOL isProductUpdated;

@property (copy) ImageLoadBlock imgLoadBlock;
@property Product *productCopy;
@end

@implementation AddWardrobeItemController

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isInitialized = NO;
    self.isTutorialPresented = NO;
    self.collectionViewHeight.constant = self.collectionView.frame.size.width/PHOTOS_PER_ROW;
    
    self.picker = [GlobalHelper createPickerForFields:@[self.conditionField, self.unitField, self.sizeField, self.shoeSizeField, self.brandField]];
    self.picker.delegate = self;
    self.picker.dataSource = self;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.sizes = @[@"size 1", @"size 2", @"size 3", @"size 4", @"size 5"];

    self.messageLabel.text = @"PHOTO";
    
   // [GlobalHelper addLogoToNavBar:self.navigationItem];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    [self.messageLabel sizeToFit];
    
    self.textViewBackground.image = [[UIImage imageNamed:@"Edit"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
    self.collectionView.allowsSelection = YES;
    self.collectionView.allowsMultipleSelection = NO;
    self.collectionView.accessibilityIdentifier = @"Photos collection";
    self.collectionView.accessibilityLabel = @"Photos collection";
    
    self.descriptionView.placeholder = @"Description";
    self.descriptionView.placeholderColor = [UIColor lightGrayColor];
    
    self.photosToDelete = [NSMutableArray new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPickerData:) name:UIKeyboardWillShowNotification object:nil];
    
    self.productCopy = [self.curProduct copy];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.curProduct == nil) {
        self.curProduct = [Product new];
        [self clearAllFields];
    } else {
        // TODO: fill in size field
        if(self.curProduct.category.name.length == 0)
            self.navigationController.title = self.curProduct.category.name;
        if(self.brandField.text.length == 0)
            self.brandField.text = self.curProduct.designer.name;
        if(self.conditionField.text.length == 0)
            self.conditionField.text = self.curProduct.condition.name;
        if(self.nameField.text.length == 0)
            self.nameField.text = self.curProduct.name;
        if(self.descriptionView.text.length == 0)
            self.descriptionView.text = self.curProduct.descriptionText;
		if(self.unitField.text.length == 0)
			self.unitField.text = self.curProduct.unit;
        if(self.sizeField.text.length == 0)
            self.sizeField.text = self.curProduct.size;
        if(self.shoeSizeField.text.length == 0)
            self.shoeSizeField.text = self.curProduct.shoeSize.name;
        if(self.heelHeightField.text.length == 0)
            self.heelHeightField.text = self.curProduct.heelHeight;
        
        if(self.curProduct.dimensions) {
            if(self.widthField.text.length == 0)
                self.widthField.text = [self.curProduct.dimensions objectAtIndex:0];
            if(self.heightField.text.length == 0)
                self.heightField.text = [self.curProduct.dimensions objectAtIndex:1];
            if(self.deepField.text.length == 0)
                self.deepField.text = [self.curProduct.dimensions objectAtIndex:2];
        }
        
        if(self.messageLabel.attributedText.length == 0 && self.curProduct.processComment != nil && self.curProduct.processComment.length > 0) {
            NSString* text = [NSString stringWithFormat:@"Our comment:\n%@", self.curProduct.processComment];
            NSMutableAttributedString *attString=[[NSMutableAttributedString alloc] initWithString:text];
            [attString addAttribute:NSFontAttributeName
                              value:[UIFont fontWithName:@"Montserrat-Light" size:17.0]
                              range:NSMakeRange(0, 12)];
            self.messageLabel.attributedText = attString;
        }
        
        [self displaySizeFieldsByCategory:self.curProduct.category];
    }
    
    EditingType editingType = [self.curProduct getEditingType];
//    [self.priceButton setEnabled:((editingType == EditingTypeAll || !self.isEditing) ? YES : NO)];
    [self.collectionView setUserInteractionEnabled:((editingType == EditingTypeAll || !self.isEditing) ? YES : NO)];
    
    if(self.isEditing && [self.curProduct.allowedTransitions linq_any:^BOOL(NSString* item) {
        return [item isEqualToString:@"product_not_available"];
    }]) {
        [self.cantSellButton setHidden:NO];
    } else {
        [self.cantSellButton setHidden:YES];
    }
    
    if(!self.isEditing && self.curProduct.category.name.length == 0) {
        [self performSegueWithIdentifier:@"chooseTopCategorySegue" sender:self];
    }
}



-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(self.isTutorialPresented) {
        [self presentCameraController: UIImagePickerControllerSourceTypeCamera];
        self.isTutorialPresented = NO;
    }
    
    self.collectionViewHeight.constant = self.collectionView.frame.size.width/PHOTOS_PER_ROW;
    
    if(self.isInitialized) {
        [self.collectionView reloadData];
    }
    
    self.isInitialized = YES;
}

- (void)setPickerData:(NSNotification*)aNotification {
    if(self.activeField == self.conditionField || self.activeField == self.unitField || self.activeField == self.sizeField || self.activeField == self.brandField ||
       self.activeField == self.shoeSizeField) {
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
			if([self.getCurrentDatasource.firstObject isKindOfClass:[NamedItem class]]) {
				NamedItem* namedItem = [[[self getCurrentDatasource] linq_where:^BOOL(NamedItem* item) {
					return [item.name isEqualToString:((UITextField*)self.activeField).text];
				}] firstObject];
				index = [[self getCurrentDatasource] indexOfObject:namedItem];
			} else {
				index = [[self getCurrentDatasource] indexOfObject:((UITextField*)self.activeField).text];
			}
        }
        
        if(index == NSNotFound) {
            index = 0;
        }
        
        [self.picker selectRow:index inComponent:0 animated:NO];
    }
	
	if(((self.activeField == self.sizeField || self.activeField == self.unitField) && [DataCache sharedInstance].units == nil) ||
       (self.activeField == self.shoeSizeField && [DataCache sharedInstance].shoeSizes == nil)) {
        if([MRProgressOverlayView overlayForView:self.picker] == nil) {
            [MRProgressOverlayView showOverlayAddedTo:self.picker  title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminateSmall animated:NO];
        }
    } else if(self.activeField == self.shoeSizeField && [DataCache sharedInstance].shoeSizes == nil) {
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
	} else if(self.activeField == self.unitField) {
		return [[DataCache sharedInstance].units.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* unit1, NSString* unit2) {
			return [unit1 compare: unit2];
		}];
	} else if(self.activeField == self.sizeField) {
		return [[[[DataCache sharedInstance].units linq_where:^BOOL(NSString* unit, id value) {
			return [unit isEqualToString:((UITextField*)self.unitField).text];
		}] allValues] firstObject];
    } else if(self.activeField == self.brandField) {
        return [DataCache sharedInstance].designers;
    } else if(self.activeField == self.shoeSizeField) {
        return [DataCache sharedInstance].shoeSizes;
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
	id item = [[self getCurrentDatasource] objectAtIndex:row];
	if([item isKindOfClass:[NSString class]]) {
		return item;
	} else if([item isKindOfClass:[NamedItem class]]) {
		  return ((NamedItem*)item).name;
	}
    return nil;
}

-(void)inputDone {
    NSInteger index = [self.picker selectedRowInComponent:0];
	if(self.activeField == self.unitField) {
		NSString* unit = [self.getCurrentDatasource objectAtIndex:index];
        
		self.unitField.text = unit;
		self.curProduct.unit = unit;
		if( self.sizeField.text.length && [[DataCache sharedInstance].units[unit] linq_where:^BOOL(NamedItem* item) {
				return (self.curProduct.sizeId && self.curProduct.sizeId == item.identifier);
			}].count == 0)
		{
			self.sizeField.text = nil;
			self.curProduct.size = nil;
			self.curProduct.sizeId = 0;
			[(UIFloatLabelTextField*)self.sizeField toggleFloatLabel:UIFloatLabelAnimationTypeHide];
		}
	} else if(self.activeField == self.sizeField) {
		NSArray* sizes = [[[[DataCache sharedInstance].units linq_where:^BOOL(NSString* unit, id value) {
			return [unit isEqualToString:((UITextField*)self.unitField).text];
		}] allValues] firstObject];
		NamedItem* size = [sizes objectAtIndex:index];
        self.sizeField.text = size.name;
        self.curProduct.size = size.name;
		self.curProduct.sizeId = size.identifier;
    } else if(self.activeField == self.brandField) {
        NamedItem* designer = [[DataCache sharedInstance].designers objectAtIndex:index];
        self.curProduct.designer = designer;
        self.brandField.text = designer.name;
    } else if(self.activeField == self.conditionField) {
        NamedItem* condition = [[DataCache sharedInstance].conditions objectAtIndex:index];
        self.curProduct.condition = condition;
        self.conditionField.text = condition.name;
        
    } else if(self.activeField == self.nameField) {
        self.curProduct.name = self.nameField.text;
    } else if(self.activeField == self.descriptionView) {
        self.curProduct.descriptionText = self.descriptionView.text;
    } else if(self.activeField == self.shoeSizeField) {
        NamedItem* shoeSize = [[DataCache sharedInstance].shoeSizes objectAtIndex:index];
        self.shoeSizeField.text = shoeSize.name;
        self.curProduct.shoeSize = shoeSize;
    } else if(self.activeField == self.heelHeightField) {
        self.curProduct.heelHeight = self.heelHeightField.text;
    } else if(self.activeField == self.widthField || self.activeField == self.heightField || self.deepField) {
        self.curProduct.dimensions = @[self.widthField.text, self.heightField.text, self.deepField.text];
    }
    
    [self.activeField resignFirstResponder];
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
            [self.collectionView reloadData];
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

#pragma mark - Segues unwind handlers

-(IBAction)unwindToAddItem:(UIStoryboardSegue*)sender {
    if([sender.sourceViewController isKindOfClass:[TopCategoriesViewController class]]) {
        TopCategoriesViewController* ccController = sender.sourceViewController;
        self.categoryField.text = ccController.selectedCategory.name;
        self.curProduct.category = ccController.selectedCategory;
        
        self.brandField.text = self.curProduct.designer.name;
        [self.collectionView reloadData];
        self.curProduct.photos = [NSMutableArray arrayWithCapacity:self.curProduct.category.imageTypes.count];
        for(int i = 0; i < self.curProduct.category.imageTypes.count; ++i) {
            [self.curProduct.photos addObject:[NSNull null]];
        }
        [self displaySizeFieldsByCategory:self.curProduct.category];
    } else if([sender.sourceViewController isKindOfClass:[TutorialController class]]) {
    } else if([sender.sourceViewController isKindOfClass:[ChooseBrandController class]]) {
        self.brandField.text = self.curProduct.designer.name;
    }
}

-(IBAction)cancelUnwindToAddItem:(UIStoryboardSegue*)sender {
    if([sender.sourceViewController isKindOfClass:[TopCategoriesViewController class]]) {
        [self cancel:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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

#pragma mark - Text fields

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    EditingType editing = [self.curProduct getEditingType];
    
    if(textField == self.categoryField) {
        return NO;
    } else if(textField == self.brandField) {
        if(!self.isEditing)
            [self performSegueWithIdentifier:@"ChooseBrandSegue2" sender:self];
        return NO;
    } else if(editing == EditingTypeAll || !self.isEditing) {
        return YES;
    } else if(editing == EditingTypeNothing) {
        return NO;
    } else if(textField == self.conditionField && editing == EditingTypeDescriptionAndCondition) {
        return YES;
    } else {
        return NO;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
    [self setPickerData:nil];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    EditingType editing = [self.curProduct getEditingType];
    
    if(textView == self.descriptionView && (editing == EditingTypeAll || editing == EditingTypeDescriptionAndCondition)) {
        return YES;
    } else {
        return NO;
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
                }];
            } else {
                [self presentViewController:picker animated:YES completion:^{
                }];
            }
        } else {
            NSLog(@"accessing the photo album");
            [self presentViewController:picker animated:YES completion:^{
            }];
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus authorizationStatus) {
                if (authorizationStatus == PHAuthorizationStatusAuthorized) {
                    // Add your custom logic here
                     NSLog(@"Authorised to see photos");
                }
                else if (authorizationStatus == PHAuthorizationStatusNotDetermined) {
                    NSLog(@"NOT Authorised to see photos");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self dismissViewControllerAnimated:YES completion:^ {
                            //Add dispatch_async as i am dismissing not on the main thread due to callback
                        }];
                    });
                }
            }];
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
    
    [self.collectionView reloadData];
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Actions

-(void)clearAllFields {
    self.categoryField.text = nil;
    self.brandField.text = nil;
	self.unitField.text = nil;
    self.sizeField.text = nil;
    self.conditionField.text = nil;
    self.descriptionView.text = nil;
    self.nameField.text = nil;
 //   self.messageLabel.attributedText = nil;
    
    self.shoeSizeField.text = nil;
    self.heelHeightField.text = nil;
    self.widthField.text = nil;
    self.heightField.text = nil;
    self.deepField.text = nil;
	
	[self.unitField setHidden:YES];
    [self.sizeField setHidden:YES];
    [self.shoeSizeField setHidden:YES];
    [self.heelHeightField setHidden:YES];
    [self.widthField setHidden:YES];
    [self.heightField setHidden:YES];
    [self.deepField setHidden:YES];
}

-(IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

-(IBAction)done:(id)sender {
    if(![self noEmptyFields] || ![self imagesAreFilled]) {
        [GlobalHelper showMessage:DefEmptyFields withTitle:@"error"];
        return;
    } else {
        if(self.activeField) {
            [self.activeField resignFirstResponder];
        }
        if (self.isEditing){
            if ([self.curProduct isEqual:self.productCopy]) {
                return;
            }
        }
        
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        
        self.curProduct.descriptionText = self.descriptionView.text;
        if(self.isEditing && [self.curProduct.processStatus isEqualToString:@"incomplete"]) {
            self.curProduct.processStatus = @"in_review_add";
        }
        
        [[ApiRequester sharedInstance] setProduct:self.curProduct success:^(Product* product){
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
//            self.curProduct.identifier = product.identifier;
//            self.curProduct.processStatus = product.processStatus;
            NSArray* oldPhotos = product.photos;
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
                    
                    Photo* photo = (i < self.curProduct.photos.count ? [_curProduct.photos objectAtIndex:i] : nil);
                    
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
                    [self clearAllFields];
                    
                    self.curProduct = nil;
                    self.isEditing = NO;
                   // [tabController setSelectedIndex:0];
                    [self dismissViewControllerAnimated:true completion:nil];
                });
            });
                                                    
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
        }];
    }
}

-(IBAction)cantSellProduct:(id)sender {
   /* [GlobalHelper askConfirmationWithTitle:@"" message:DefCantSellWarning yes:^{
        MainTabBarController* tabController = (MainTabBarController*)self.tabBarController;
        WardrobeController* wc = (WardrobeController*)[[tabController.viewControllers objectAtIndex:0] visibleViewController];
        
        [MRProgressOverlayView showOverlayAddedTo:[UIApplication sharedApplication].keyWindow title:@"Loading..." mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [[ApiRequester sharedInstance] setProcessStatus:@"product_not_available" forProduct:self.curProduct.identifier success:^(Product *product) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            self.curProduct.processStatus = @"product_not_available";
            [wc updateProductsList];
            [self clearAllFields];
            self.curProduct = nil;
            self.isEditing = NO;
            [tabController setSelectedIndex:0];
        } failure:^(NSString *error) {
            [MRProgressOverlayView dismissOverlayForView:[UIApplication sharedApplication].keyWindow animated:YES];
            [GlobalHelper showMessage:error withTitle:@"error"];
        }];
    } no:nil]; */
}

#pragma mark - Photo collection

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.curProduct.photos.count + 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString* reuseId = [NSString stringWithFormat:@"reuse%zd", indexPath.row];
    __block PhotoCell* newCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
//    PhotoCell* newCell = [PhotoCell new];
    
    // Handle "plus" item
    if(indexPath.row == self.curProduct.photos.count) {
        newCell.photoView.image = [UIImage imageNamed:@"plus"];
        [newCell.photoTypeLabel setHidden:YES];
    } else {
        ImageType* imgType = nil;
        if(indexPath.row >= self.curProduct.category.imageTypes.count) {
            imgType = [ImageType new];
            imgType.name = [NSString stringWithFormat:@"%zd", indexPath.row - self.curProduct.category.imageTypes.count + 1];
        } else {
            imgType = [self.curProduct.category.imageTypes objectAtIndex:indexPath.row];
        }
        
        newCell.photoTypeLabel.text = imgType.name;
        [newCell.photoTypeLabel setHidden:NO];
        
        if(self.curProduct.photos != nil && self.curProduct.photos.count >= (indexPath.row + 1)) {
            Photo* photo = [self.curProduct.photos objectAtIndex:indexPath.row];
            if(photo != nil && [photo isKindOfClass:[Photo class]]) {
                if(photo.image != nil) {
                    newCell.photoView.image = photo.image;
                } else {
                    [newCell.photoView sd_setImageWithURL:[NSURL URLWithString:photo.thumbnailUrl] placeholderImage:[UIImage imageNamed:@"stub"]];
                }
            } else {
                [newCell.photoView sd_setImageWithURL:[NSURL URLWithString:imgType.preview] placeholderImage:[UIImage imageNamed:@"stub"]];
            }
        } else {
            [newCell.photoView sd_setImageWithURL:[NSURL URLWithString:imgType.preview] placeholderImage:[UIImage imageNamed:@"stub"]];
        }
    }
    
    UITapGestureRecognizer* tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    [newCell.photoView addGestureRecognizer:tapRecognizer];
    
    newCell.photoView.tag = indexPath.row;
    newCell.accessibilityLabel = [NSString stringWithFormat:@"Photo cell %td", indexPath.row];
    return newCell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemSize = collectionView.frame.size.width/PHOTOS_PER_ROW;
    return CGSizeMake(itemSize, itemSize);
}

- (void) handleTapFrom: (UITapGestureRecognizer *)recognizer {
    self.selectedImageIndex = recognizer.view.tag;
    
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

#pragma mark - Product size

-(void)displaySizeFieldsByCategory:(STCategory*)category {
    
    NSInteger sizeFieldsHeight = (category.sizeFields ? 38 : 0);
    for (NSLayoutConstraint* heightConstraint in self.sfHeightConstraints) {
        heightConstraint.constant = sizeFieldsHeight;
    }
    
    if(!category.sizeFields) {
        [self.unitField setHidden:YES];
        [self.sizeField setHidden:YES];
        [self.shoeSizeField setHidden:YES];
        [self.heelHeightField setHidden:YES];
        [self.widthField setHidden:YES];
        [self.heightField setHidden:YES];
        [self.deepField setHidden:YES];
        return;
    }
    
    NSString* firstSize = [category.sizeFields firstObject];
    if([firstSize isEqualToString:@"size"]) {
		[self.unitField setHidden:NO];
        [self.sizeField setHidden:NO];
        [self.shoeSizeField setHidden:YES];
        [self.heelHeightField setHidden:YES];
        [self.widthField setHidden:YES];
        [self.heightField setHidden:YES];
        [self.deepField setHidden:YES];
    } else if([firstSize isEqualToString:@"shoesize"]) {
		[self.unitField setHidden:YES];
        [self.sizeField setHidden:YES];
        [self.shoeSizeField setHidden:NO];
        [self.heelHeightField setHidden:NO];
        [self.widthField setHidden:YES];
        [self.heightField setHidden:YES];
        [self.deepField setHidden:YES];
    } else if([firstSize isEqualToString:@"dimensions"]) {
		[self.unitField setHidden:YES];
        [self.sizeField setHidden:YES];
        [self.shoeSizeField setHidden:YES];
        [self.heelHeightField setHidden:YES];
        [self.widthField setHidden:NO];
        [self.heightField setHidden:NO];
        [self.deepField setHidden:NO];
    }
}

-(BOOL)noEmptyFields {
    NSString* firstSize = [self.curProduct.category.sizeFields firstObject];
    BOOL isSizeFilled = NO;
    if([firstSize isEqualToString:@"size"]) {
        isSizeFilled = (self.sizeField.text.length > 0);
    } else if([firstSize isEqualToString:@"shoesize"]) {
        isSizeFilled = (self.shoeSizeField.text.length > 0 /*&& self.heelHeightField.text.length > 0*/);
    } else if([firstSize isEqualToString:@"dimensions"]) {
        isSizeFilled = (self.widthField.text.length > 0 && self.heightField.text.length > 0 && self.deepField.text.length > 0);
    }
    
    if([self.curProduct.category.name isEqualToString:@"BAGS"]) {
        isSizeFilled = YES;
    }
    
    if(!self.curProduct.category.sizeFields)
        isSizeFilled = YES;
    
    if(self.categoryField.text.length == 0 ||
       self.descriptionView.text.length == 0 ||
       self.brandField.text.length == 0 ||
       self.conditionField.text.length == 0 ||
       self.nameField.text.length == 0 ||
       !isSizeFilled ||
       self.curProduct.price == 0 ||
       self.curProduct.originalPrice == 0) {
        return NO;
    } else {
        return YES;
    }
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
