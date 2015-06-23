//
//  Designer.h
//  StyleTribute
//
//  Created by selim mustafaev on 23/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"

@interface Designer : BaseModel

@property NSString* identifier;
@property NSString* name;

+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
