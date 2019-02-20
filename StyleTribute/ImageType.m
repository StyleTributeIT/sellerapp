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
    imgType.type = [[self class] parseString:@"label" fromDict:dict];
    imgType.preview = [[self class] parseString:@"preview_image_file" fromDict:dict];
    imgType.outline = [[self class] parseString:@"outline_image_file" fromDict:dict];
    imgType.state = ImageStateNormal;
    
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
    self.state = [[decoder decodeObjectForKey:@"state"] unsignedIntegerValue];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.preview forKey:@"preview"];
    [encoder encodeObject:self.outline forKey:@"outline"];
    [encoder encodeObject:@(self.state) forKey:@"state"];
}
@end
