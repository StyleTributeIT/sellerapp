//
//  Country.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 26/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"

@interface Country : BaseModel<NSCoding>

@property NSString* identifier;
@property NSString* name;

+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
