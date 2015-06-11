//
//  ImageType.h
//  StyleTribute
//
//  Created by selim mustafaev on 11/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"

@interface ImageType : BaseModel

@property NSString* name;
@property NSString* type;
@property NSString* preview;
@property NSString* outline;

+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
