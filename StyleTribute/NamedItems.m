//
//  BaseItem.m
//  StyleTribute
//
//  Created by selim mustafaev on 24/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "NamedItems.h"

@interface NamedItem () <NSCoding>

@end

@implementation NamedItem

+(instancetype)parseFromJson:(NSDictionary*)dict {
    
    NamedItem *item = [self new];
    
    item.identifier = (NSUInteger)[[self parseString:@"id" fromDict:dict] integerValue];
    item.name = [self parseString:@"name" fromDict:dict];
    
    return item;
}

#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.identifier = [[decoder decodeObjectForKey:@"id"] unsignedIntegerValue];
    self.name = [decoder decodeObjectForKey:@"name"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.identifier) forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
}

@end
