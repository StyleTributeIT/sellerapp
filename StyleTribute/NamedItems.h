//
//  BaseItem.h
//  StyleTribute
//
//  Created by selim mustafaev on 24/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"

@interface NamedItem : BaseModel<NSCopying> 

@property NSUInteger identifier;
@property NSString* name;

+(instancetype)parseFromJson:(NSDictionary*)dict;
-(instancetype)initWithName:(NSString*)name andId:(NSUInteger)identifier;

@end
