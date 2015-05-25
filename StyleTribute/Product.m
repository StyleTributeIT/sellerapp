//
//  Product.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Product.h"

@implementation Product

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
    
    self.title = [decoder decodeObjectForKey:@"title"];
    self.displayState = [decoder decodeObjectForKey:@"display_state"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.displayState forKey:@"display_state"];
}

@end
