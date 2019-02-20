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

- (id)copyWithZone:(NSZone *)zone
{
    NamedItem *newNameItem = [[NamedItem allocWithZone:zone]init];
    newNameItem.name = [_name copy];
    newNameItem.identifier = _identifier;
	
	return newNameItem;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]){
        NamedItem *namedItem = (NamedItem *) object;
        
        if (!(namedItem.identifier && _identifier && namedItem.identifier == _identifier)){
            if (!(!namedItem.identifier && !_identifier)) {
                return NO;
            }
        }
        if (!(namedItem.name && _name && [namedItem.name isEqualToString:_name])){
            if (!(!namedItem.name && !_name)) {
                return NO;
            }
        }
    }else{
        return NO;
    }
	return YES;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"id: %lu, name: %@", (unsigned long)self.identifier, self.name];
}

+(instancetype)parseFromJson:(NSDictionary*)dict {
    
    NamedItem *item = [self new];
    item.identifier = [[dict valueForKey:@"id"] integerValue];
    item.name = [self parseString:@"name" fromDict:dict];
    
    return item;
}

-(instancetype)initWithName:(NSString*)name andId:(NSUInteger)identifier {
    self = [super init];
    if(self) {
        self.identifier = identifier;
        self.name = name;
    }
    return self;
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
