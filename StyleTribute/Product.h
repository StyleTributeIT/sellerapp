//
//  Product.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import "Category.h"
#import "ProductPhoto.h"
#import "NamedItems.h"

typedef NS_ENUM(NSUInteger, ProductType) {
    ProductTypeSelling,
    ProductTypeSold,
    ProductTypeArchived,
    ProductTypeNonVisible
};

typedef NS_ENUM(NSUInteger, EditingType) {
    EditingTypeAll,
    EditingTypeDescriptionAndCondition,
    EditingTypeNothing
};

@interface Product : BaseModel<NSCoding>

@property NSUInteger identifier;
@property ProductType type;
@property NSString* name;
@property NSString* processStatus;
@property STCategory* category;
@property NSMutableArray* photos;
@property NamedItem* designer;
@property NamedItem* condition;
@property float originalPrice;
@property float price;
@property NSMutableArray* allowedTransitions;
@property NSString* descriptionText;

-(instancetype)init;
+(instancetype)parseFromJson:(NSDictionary*)dict;

-(ProductType)getProductType;
-(EditingType)getEditingType;

@end
