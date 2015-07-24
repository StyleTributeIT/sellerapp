//
//  Product.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Product.h"
#import "Photo.h"

@implementation Product

-(instancetype)init {
    self = [super init];
    if(self) {
        self.type = ProductTypeSelling;
        self.identifier = 0;
    }
    return self;
}

+(instancetype)parseFromJson:(NSDictionary*)dict {
    Product* product = [Product new];
    
    product.identifier = (NSUInteger)[[self parseString:@"id" fromDict:dict] integerValue];
    product.name = [self parseString:@"name" fromDict:dict];
    product.processStatus = [self parseString:@"process_status" fromDict:dict];
    product.originalPrice = [[self parseString:@"original_price" fromDict:dict] floatValue];
    product.price = [[self parseString:@"price" fromDict:dict] floatValue];
    
    product.allowedTransitions = [NSMutableArray new];
    NSArray* transitionsArray = [dict objectForKey:@"allowed_transitions"];
    if(transitionsArray != nil) for(NSString* transition in transitionsArray) {
        [product.allowedTransitions addObject:transition];
    }
    
    product.photos = [NSMutableArray new];
    NSArray* images = [dict objectForKey:@"images"];
    if(images != nil) for(NSDictionary* imageDict in images) {
        Photo* photo = [Photo parseFromJson:imageDict];
        [product.photos addObject:photo];
    }
    
    return product;
}

#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.identifier = [[decoder decodeObjectForKey:@"id"] unsignedIntegerValue];
    self.type = [[decoder decodeObjectForKey:@"type"] unsignedIntegerValue];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.processStatus = [decoder decodeObjectForKey:@"processStatus"];
    self.category = [decoder decodeObjectForKey:@"category"];
    self.photos = [decoder decodeObjectForKey:@"photos"];
    self.originalPrice = [[decoder decodeObjectForKey:@"originalPrice"] floatValue];
    self.price = [[decoder decodeObjectForKey:@"price"] floatValue];
    self.allowedTransitions = [decoder decodeObjectForKey:@"allowedTransitions"];
    self.descriptionText = [decoder decodeObjectForKey:@"descriptionText"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.identifier) forKey:@"id"];
    [encoder encodeObject:@(self.type) forKey:@"type"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.processStatus forKey:@"processStatus"];
    [encoder encodeObject:self.category forKey:@"category"];
    [encoder encodeObject:self.photos forKey:@"photos"];
    [encoder encodeObject:@(self.originalPrice) forKey:@"originalPrice"];
    [encoder encodeObject:@(self.price) forKey:@"price"];
    [encoder encodeObject:self.allowedTransitions forKey:@"allowedTransitions"];
    [encoder encodeObject:self.descriptionText forKey:@"descriptionText"];
}

@end
