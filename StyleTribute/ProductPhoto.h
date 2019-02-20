//
//  ProductImage.h
//  StyleTribute
//
//  Created by selim mustafaev on 11/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"
#import "ImageType.h"
#import <UIKit/UIKit.h>

@interface ProductPhoto : BaseModel

@property ImageType* type;
@property UIImage* image;

@end
