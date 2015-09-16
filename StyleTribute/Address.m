//
//  Address.m
//  StyleTribute
//
//  Created by selim mustafaev on 16/09/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Address.h"

@implementation Address

+(instancetype)parseFromJson:(NSDictionary*)dict {
    
    Address *item = [self new];
    
    item.firstName = [self parseString:@"firstname" fromDict:dict];
    item.lastName = [self parseString:@"lastname" fromDict:dict];
    item.company = [self parseString:@"company" fromDict:dict];
    item.address = [self parseString:@"street" fromDict:dict];
    item.city = [self parseString:@"city" fromDict:dict];
    item.zipCode = [self parseString:@"postcode" fromDict:dict];
    item.countryId = [self parseString:@"country_id" fromDict:dict];
    item.contactNumber = [self parseString:@"telephone" fromDict:dict];
    
    NSString* region = [self parseString:@"region" fromDict:dict];
    NSUInteger regionId = (NSUInteger)[[self parseString:@"region_id" fromDict:dict] integerValue];
    item.state = [[NamedItem alloc] initWithName:region andId:regionId];
    
    return item;
}

#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.firstName = [decoder decodeObjectForKey:@"firstName"];
    self.lastName = [decoder decodeObjectForKey:@"lastName"];
    self.company = [decoder decodeObjectForKey:@"company"];
    self.address = [decoder decodeObjectForKey:@"address"];
    self.city = [decoder decodeObjectForKey:@"city"];
    self.state = [decoder decodeObjectForKey:@"state"];
    self.zipCode = [decoder decodeObjectForKey:@"zipCode"];
    self.countryId = [decoder decodeObjectForKey:@"countryId"];
    self.contactNumber = [decoder decodeObjectForKey:@"contactNumber"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.firstName forKey:@"firstName"];
    [encoder encodeObject:self.lastName forKey:@"lastName"];
    [encoder encodeObject:self.company forKey:@"company"];
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.city forKey:@"city"];
    [encoder encodeObject:self.state forKey:@"state"];
    [encoder encodeObject:self.zipCode forKey:@"zipCode"];
    [encoder encodeObject:self.countryId forKey:@"countryId"];
    [encoder encodeObject:self.contactNumber forKey:@"contactNumber"];
}

@end
