//
//  Photo.m
//  StyleTribute
//
//  Created by selim mustafaev on 23/07/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Photo.h"

@implementation Photo

+(instancetype)parseFromJson:(NSDictionary*)dict {
    
    
    Photo *item = [self new];
    item.identifier = (NSUInteger)[[self parseString:@"id" fromDict:dict] integerValue];
    item.label = [self parseString:@"label" fromDict:dict];
    item.imageUrl = [self parseString:@"file" fromDict:dict];
    item.thumbnailUrl = [@"https://mediatest.styletribute.com" stringByAppendingString:[self parseString:@"thumbnail_image" fromDict:dict]];
    
    return item;
}

#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.identifier = [[decoder decodeObjectForKey:@"id"] unsignedIntegerValue];
    self.label = [decoder decodeObjectForKey:@"label"];
    self.image = [decoder decodeObjectForKey:@"image"];
    self.imageUrl = [decoder decodeObjectForKey:@"imageUrl"];
    self.thumbnailUrl = [decoder decodeObjectForKey:@"thumbnailUrl"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.identifier) forKey:@"id"];
    [encoder encodeObject:self.label forKey:@"label"];
    [encoder encodeObject:self.image forKey:@"image"];
    [encoder encodeObject:self.imageUrl forKey:@"imageUrl"];
    [encoder encodeObject:self.thumbnailUrl forKey:@"thumbnailUrl"];
}

@end
