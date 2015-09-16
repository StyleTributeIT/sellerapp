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
	typeof(self) copy = [[[self class] alloc] init];
	
	if (copy) {
		// Copy NSObject subclasses
		copy.name = [self.name copyWithZone:zone];
		
		// Set primitives
		copy.identifier = self.identifier;
	}
	
	return copy;
}

- (BOOL)isEqual:(id)object {
	return [self.name isEqualToString:((NamedItem *)object).name] && (self.identifier == ((NamedItem *)object).identifier);
}

- (NSString*)description {
	return [NSString stringWithFormat:@"id: %u, name: %@", self.identifier, self.name];
}

+(instancetype)parseFromJson:(NSDictionary*)dict {
    
    NamedItem *item = [self new];
    
    item.identifier = (NSUInteger)[[self parseString:@"id" fromDict:dict] integerValue];
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
