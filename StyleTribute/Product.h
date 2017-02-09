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

@interface Product : BaseModel<NSCoding,NSCopying>

@property NSUInteger identifier;
@property ProductType type;
@property NSString* name;
@property NSString* processStatus;
@property NSString* processStatusDisplay;
@property NSString* processComment;
@property STCategory* category;
@property NSMutableArray* photos;
@property NamedItem* designer;
@property NamedItem* other_designer;
@property NamedItem* condition;
@property float originalPrice;
@property float suggestedPrice;
@property float savedPrice;
@property float price;
@property NSMutableArray* allowedTransitions;

@property NSString* descriptionText;
@property NSString* unit;
@property NSString* size;
@property NSString* kidzsize;
@property NSString* url;
@property NSString* share_text;
@property NSUInteger sizeId;
@property NamedItem* shoeSize;
@property NSString* heelHeight;
@property NSArray* dimensions;

-(instancetype)init;
+(instancetype)parseFromJson:(NSDictionary*)dict;

-(ProductType)getProductType;
-(EditingType)getEditingType;
-(NSString*)getProductStatus;

@end
