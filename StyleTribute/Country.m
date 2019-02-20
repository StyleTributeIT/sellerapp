//
//  Country.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 26/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Country.h"

@implementation Country

+(instancetype)parseFromJson:(NSDictionary*)dict; {
    
    Country* country = [Country new];
    country.identifier = [[self class] parseString:@"alpha2Code" fromDict:dict];
    country.name = [[self class] parseString:@"name" fromDict:dict];
    
    return country;
}

#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.identifier = [decoder decodeObjectForKey:@"id"];
    self.name = [decoder decodeObjectForKey:@"name"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.identifier forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
}

@end
