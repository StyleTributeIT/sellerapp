//
//  Product.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Product.h"

@implementation Product

-(instancetype)init {
    self = [super init];
    if(self) {
        self.type = ProductTypeSelling;
    }
    return self;
}

+(instancetype)parseFromJson:(NSDictionary*)dict; {
    Product* product = [Product new];
    
    product.title = [[self class] parseString:@"title" fromDict:dict];
    product.displayState = [[self class] parseString:@"display_state" fromDict:dict];
    
    return product;
}

#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.type = [[decoder decodeObjectForKey:@"type"] unsignedIntegerValue];
    self.title = [decoder decodeObjectForKey:@"title"];
    self.displayState = [decoder decodeObjectForKey:@"display_state"];
    self.category = [decoder decodeObjectForKey:@"category"];
    self.photos = [decoder decodeObjectForKey:@"photos"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.type) forKey:@"type"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.displayState forKey:@"display_state"];
    [encoder encodeObject:self.category forKey:@"category"];
    [encoder encodeObject:self.photos forKey:@"photos"];
}

@end
