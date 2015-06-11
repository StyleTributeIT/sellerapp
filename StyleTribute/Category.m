//
//  Category.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Category.h"
#import "ImageType.h"

@interface STCategory () <NSCoding>

@end

@implementation STCategory

+(instancetype)parseFromJson:(NSDictionary*)dict; {
    STCategory* category = [STCategory new];

    category.idNum = [[self class] parseUInteger:@"id" fromDict:dict];
    category.name = [[self class] parseString:@"name" fromDict:dict];
    category.thumbnail = [[self class] parseString:@"thumbnail" fromDict:dict];
    
    NSMutableArray* imgTypes = [NSMutableArray new];
    NSDictionary* imgTypeArray = [dict objectForKey:@"image_types"];
    if(imgTypeArray != nil) for(NSDictionary* imgTypeDict in imgTypeArray) {
        ImageType* imgType = [ImageType parseFromJson:imgTypeDict];
        [imgTypes addObject:imgType];
    }
    category.imageTypes = imgTypes;
    
    return category;
}

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.idNum = [[decoder decodeObjectForKey:@"id"] unsignedIntegerValue];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
    self.imageTypes = [decoder decodeObjectForKey:@"imageTypes"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.idNum) forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.thumbnail forKey:@"thumbnail"];
    [encoder encodeObject:self.imageTypes forKey:@"imageTypes"];
}

@end
