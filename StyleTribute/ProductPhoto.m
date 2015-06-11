//
//  ProductImage.m
//  StyleTribute
//
//  Created by selim mustafaev on 11/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ProductPhoto.h"

@interface ProductPhoto () <NSCoding>

@end

@implementation ProductPhoto

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.type = [decoder decodeObjectForKey:@"type"];
    self.image = [decoder decodeObjectForKey:@"image"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.image forKey:@"image"];
}

@end
