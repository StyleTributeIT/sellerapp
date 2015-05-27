//
//  Category.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Category.h"

@implementation STCategory

+(instancetype)parseFromJson:(NSDictionary*)dict; {
    STCategory* category = [STCategory new];

    category.idNum = [[self class] parseUInteger:@"id" fromDict:dict];
    category.idStr = [[self class] parseString:@"ident" fromDict:dict];
    category.name = [[self class] parseString:@"name" fromDict:dict];
    category.productCount = [[self class] parseUInteger:@"productCount" fromDict:dict];
    
    return category;
}

@end
