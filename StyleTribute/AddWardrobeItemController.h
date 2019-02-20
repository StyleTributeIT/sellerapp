//
//  AddWardrobeItemController.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 30/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseInputController.h"
#import "Product.h"
#import <UIKit/UIKit.h>

@interface AddWardrobeItemController : BaseInputController<UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate>

@property IBOutlet UILabel* messageLabel;
@property IBOutlet UITextField* nameField;
@property IBOutlet UITextField* categoryField;
@property IBOutlet UITextField* conditionField;
@property IBOutlet UITextView* descriptionView;
@property IBOutlet UITextField* brandField;
@property IBOutlet UITextField* unitField;
@property IBOutlet UITextField* sizeField;
@property IBOutlet UIImageView* textViewBackground;
@property IBOutlet UICollectionView* collectionView;
@property IBOutlet NSLayoutConstraint* collectionViewHeight;
@property IBOutlet UIButton* priceButton;
@property IBOutlet UIButton* cantSellButton;
@property IBOutlet UITextField* shoeSizeField;
@property IBOutlet UITextField* heelHeightField;
@property IBOutlet UITextField* widthField;
@property IBOutlet UITextField* heightField;
@property IBOutlet UITextField* deepField;

@property IBOutletCollection(NSLayoutConstraint) NSArray *sfHeightConstraints;

@property Product* curProduct;
@property BOOL isEditing;

@end
