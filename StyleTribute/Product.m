//
//  Product.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Product.h"
#import "Photo.h"
#import "DataCache.h"
#import <NSArray+LinqExtensions.h>

@implementation Product

-(instancetype)init {
    self = [super init];
    if(self) {
        self.type = ProductTypeSelling;
        self.processStatus = @"in_review";
        self.identifier = 0;
    }
    return self;
}

+(instancetype)parseFromJson:(NSDictionary*)dict {
    Product* product = [Product new];
    
    product.identifier = (NSUInteger)[self parseLong:@"id" fromDict:dict];
    product.name = [self parseString:@"name" fromDict:dict];
    product.processStatus = [self parseString:@"process_status" fromDict:dict];
    product.originalPrice = [[self parseString:@"original_price" fromDict:dict] floatValue];
    product.price = [[self parseString:@"price" fromDict:dict] floatValue];
    product.descriptionText = [self parseString:@"description" fromDict:dict];
    
    product.allowedTransitions = [NSMutableArray new];
    NSArray* transitionsArray = [dict objectForKey:@"allowed_transitions"];
    if(transitionsArray != nil) for(NSString* transition in transitionsArray) {
        [product.allowedTransitions addObject:transition];
    }
    
    // Uncomment this to test transitions
//    [product.allowedTransitions addObject:@"archived"];
//    [product.allowedTransitions addObject:@"deleted"];
    
    if([DataCache sharedInstance].categories != nil) {
        NSUInteger categoryId = (NSUInteger)[[dict objectForKey:@"category"] integerValue];
        product.category = [[[DataCache sharedInstance].categories linq_where:^BOOL(STCategory* category) {
            return (category.idNum == categoryId);
        }] firstObject];
    }
    
    if([DataCache sharedInstance].conditions != nil) {
        NSUInteger conditionId = (NSUInteger)[[dict objectForKey:@"condition"] integerValue];
        product.condition = [[[DataCache sharedInstance].conditions linq_where:^BOOL(NamedItem* condition) {
            return (condition.identifier == conditionId);
        }] firstObject];
    }
    
    if([DataCache sharedInstance].designers != nil) {
        NSUInteger designerId = (NSUInteger)[[dict objectForKey:@"designer"] integerValue];
        product.designer = [[[DataCache sharedInstance].designers linq_where:^BOOL(NamedItem* designer) {
            return (designer.identifier == designerId);
        }] firstObject];
    }
    
    product.photos = [[NSMutableArray alloc] initWithCapacity:product.category.imageTypes.count];
    for(int i = 0; i < product.category.imageTypes.count; ++i) {
        [product.photos addObject:[NSNull null]];
    }
    
    NSArray* images = [dict objectForKey:@"images"];
    if(images != nil) for(NSDictionary* imageDict in images) {
        Photo* photo = [Photo parseFromJson:imageDict];

        ImageType* type = [[product.category.imageTypes linq_where:^BOOL(ImageType* imgType) {
            return [imgType.type isEqualToString:photo.label];
        }] firstObject];
        
        if(type != nil) {
            NSUInteger index = [product.category.imageTypes indexOfObject:type];
            if(index < product.photos.count) {
                [product.photos replaceObjectAtIndex:index withObject:photo];
            }
        }
    }
    
    NSDictionary* dimensions = [dict objectForKey:@"dimensions"];
    if(dimensions) {
        NSString* width = [self parseString:@"width" fromDict:dimensions];
        NSString* height = [self parseString:@"height" fromDict:dimensions];
        NSString* depth = [self parseString:@"depth" fromDict:dimensions];
        product.dimensions = @[width, height, depth];
    }
	
	product.sizeId = [self parseInt:@"size" fromDict:dict];
    product.shoeSize = [self parseString:@"shoesize" fromDict:dict];
    product.heelHeight = [self parseString:@"heel_height" fromDict:dict];
	
	// sizeId -> unit  & size
	if(product.sizeId && [DataCache sharedInstance].units != nil) {
		[[DataCache sharedInstance].units enumerateKeysAndObjectsUsingBlock:^(NamedItem* unit, NSArray* sizes, BOOL *stop) {
			for(NamedItem* size in sizes) {
				if(size.identifier == product.sizeId) {
					product.unit = unit.name;
					product.size = size.name;
					
					*stop = YES;
					break;
				}
			}
		}];
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
	self.unit = [decoder decodeObjectForKey:@"unit"];
    self.size = [decoder decodeObjectForKey:@"size"];
    self.shoeSize = [decoder decodeObjectForKey:@"shoeSize"];
    self.heelHeight = [decoder decodeObjectForKey:@"heelHeight"];
    self.dimensions = [decoder decodeObjectForKey:@"dimensions"];
    
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
	[encoder encodeObject:self.unit forKey:@"unit"];
    [encoder encodeObject:self.size forKey:@"size"];
    [encoder encodeObject:self.shoeSize forKey:@"shoeSize"];
    [encoder encodeObject:self.heelHeight forKey:@"heelHeight"];
    [encoder encodeObject:self.dimensions forKey:@"dimensions"];
}

#pragma mark - Helpers

-(ProductType)getProductType {
    if([self.processStatus isEqualToString:@"new"] ||
       [self.processStatus isEqualToString:@"in_review"] ||
       [self.processStatus isEqualToString:@"in_review_add"] ||
       [self.processStatus isEqualToString:@"incomplete"] ||
       [self.processStatus isEqualToString:@"image_processing"] ||
       [self.processStatus isEqualToString:@"selling"] ||
       [self.processStatus isEqualToString:@"suspended"])
    {
        return ProductTypeSelling;
    }
    else if([self.processStatus isEqualToString:@"sold"] ||
            [self.processStatus isEqualToString:@"sold_confirmed"] ||
            [self.processStatus isEqualToString:@"received"] ||
            [self.processStatus isEqualToString:@"authenticated"] ||
            [self.processStatus isEqualToString:@"sent_to_buyer"] ||
            [self.processStatus isEqualToString:@"received_by_buyer"] ||
            [self.processStatus isEqualToString:@"payout_seller"] ||
            [self.processStatus isEqualToString:@"complete"])
    {
        return ProductTypeSold;
    }
    else if([self.processStatus isEqualToString:@"archived"])
    {
        return ProductTypeArchived;
    }
    
    return ProductTypeNonVisible;
}

-(EditingType)getEditingType {
    if([self.processStatus isEqualToString:@"in_review"] ||
       [self.processStatus isEqualToString:@"in_review_add"] ||
       [self.processStatus isEqualToString:@"incomplete"])
    {
        return EditingTypeAll;
    }
    else if([self.processStatus isEqualToString:@"image_processing"] ||
            [self.processStatus isEqualToString:@"selling"])
    {
        return EditingTypeDescriptionAndCondition;
    }
    else
    {
        return EditingTypeNothing;
    }
}

@end
