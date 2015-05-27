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
@property NSString* idStr;
@property NSString* name;
@property NSUInteger productCount;

+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
