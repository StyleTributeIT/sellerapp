//
//  Photo.h
//  StyleTribute
//
//  Created by selim mustafaev on 23/07/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"
#import <UIKit/UIKit.h>

@interface Photo : BaseModel

@property NSUInteger identifier;
@property UIImage* image;
@property NSString* imageUrl;
@property NSString* thumbnailUrl;
@property NSString* label;

+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
