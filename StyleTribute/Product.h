//
//  Product.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject<NSCoding>

@property NSString* title;
@property NSString* displayState;

+(Product*)parseFromJson:(NSDictionary*)dict;

@end
