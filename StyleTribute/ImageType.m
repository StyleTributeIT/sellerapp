//
//  ImageType.m
//  StyleTribute
//
//  Created by selim mustafaev on 11/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ImageType.h"

@interface ImageType () <NSCoding>

@end

@implementation ImageType

+(instancetype)parseFromJson:(NSDictionary*)dict {
    ImageType* imgType = [ImageType new];
    
    imgType.name = [[self class] parseString:@"name" fromDict:dict];
    imgType.type = [[self class] parseString:@"type" fromDict:dict];
    
    imgType.preview = [[self class] parseString:@"preview_image" fromDict:dict];
    imgType.outline = [[self class] parseString:@"outline_image" fromDict:dict];
    
    // FIXME: remove replacing after backend fix
    if([imgType.preview rangeOfString:@"catalog/category"].location == NSNotFound) {
        imgType.preview = [imgType.preview stringByReplacingOccurrencesOfString:@"media" withString:@"media/catalog/category"];
        imgType.outline = [imgType.outline stringByReplacingOccurrencesOfString:@"media" withString:@"media/catalog/category"];
    }
    
    return imgType;
}

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.name = [decoder decodeObjectForKey:@"name"];
    self.type = [decoder decodeObjectForKey:@"type"];
    self.preview = [decoder decodeObjectForKey:@"preview"];
    self.outline = [decoder decodeObjectForKey:@"outline"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.preview forKey:@"preview"];
    [encoder encodeObject:self.outline forKey:@"outline"];
}
@end
