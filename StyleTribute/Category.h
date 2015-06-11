//
//  Category.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"

@interface STCategory : BaseModel

@property NSUInteger idNum;
@property NSString* name;
@property NSString* thumbnail;
@property NSArray* imageTypes;

+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
