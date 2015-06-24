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

typedef enum : NSUInteger {
    ProductTypeSelling,
    ProductTypeSold,
    ProductTypeArchived,
} ProductType;

@interface Product : BaseModel<NSCoding>

@property ProductType type;
@property NSString* title;
@property NSString* displayState;
@property STCategory* category;
@property NSArray* photos;
@property NamedItem* designer;
@property NamedItem* condition;

-(instancetype)init;
+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
