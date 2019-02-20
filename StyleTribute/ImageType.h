//
//  ImageType.h
//  StyleTribute
//
//  Created by selim mustafaev on 11/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"

typedef NS_ENUM(NSUInteger, ImageState) {
    ImageStateNormal,
    ImageStateNew,
    ImageStateModified,
    ImageStateDeleted
};

@interface ImageType : BaseModel

@property NSString* name;
@property NSString* type;
@property NSString* preview;
@property NSString* outline;
@property ImageState state;

+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
