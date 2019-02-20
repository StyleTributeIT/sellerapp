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
    NSLog(@"%@",dict);
    
    Address *item = [self new];
    
    item.firstName = [self parseString:@"first_name" fromDict:dict];
    item.lastName = [self parseString:@"last_name" fromDict:dict];
    item.company = [self parseString:@"company" fromDict:dict];
    item.address = [self parseString:@"street" fromDict:dict];
    item.city = [self parseString:@"city" fromDict:dict];
    item.zipCode = [self parseString:@"zipcode" fromDict:dict];
    item.countryId = [self parseString:@"phone_code" fromDict:dict];
    item.contactNumber = [self parseString:@"phone" fromDict:dict];
    item.cusomer_id = [self parseString:@"cusomer_id" fromDict:dict];
    item.firstlineaddress =  [self parseString:@"address_1" fromDict:dict];
    item.secondlineaddress = [self parseString:@"address_2" fromDict:dict];
    NSString* region = [self parseString:@"region" fromDict:dict];
    NSUInteger regionId = (NSUInteger)[[self parseString:@"region_id" fromDict:dict] integerValue];
    item.state = [[NamedItem alloc] initWithName:region andId:regionId];
    
    return item;
}
//
//#pragma mark - NSCoding
//
//-(instancetype)initWithCoder:(NSCoder *)decoder {
//    self = [super init];
//    if(!self) {
//        return nil;
//    }
//    
//    self.firstName = [decoder decodeObjectForKey:@"firstName"];
//    self.lastName = [decoder decodeObjectForKey:@"lastName"];
//    self.company = [decoder decodeObjectForKey:@"company"];
//    self.address = [decoder decodeObjectForKey:@"address"];
//    self.city = [decoder decodeObjectForKey:@"city"];
//    self.state = [decoder decodeObjectForKey:@"state"];
//    self.zipCode = [decoder decodeObjectForKey:@"zipCode"];
//    self.countryId = [decoder decodeObjectForKey:@"countryId"];
//    self.contactNumber = [decoder decodeObjectForKey:@"contactNumber"];
//    self.firstlineaddress = [decoder decodeObjectForKey:@"firstlineaddress"];
//    self.secondlineaddress = [decoder decodeObjectForKey:@"secondlineaddress"];
//    return self;
//}
//
//-(void)encodeWithCoder:(NSCoder *)encoder {
//    [encoder encodeObject:self.firstName forKey:@"firstName"];
//    [encoder encodeObject:self.lastName forKey:@"lastName"];
//    [encoder encodeObject:self.company forKey:@"company"];
//    [encoder encodeObject:self.address forKey:@"address"];
//    [encoder encodeObject:self.city forKey:@"city"];
//    [encoder encodeObject:self.state forKey:@"state"];
//    [encoder encodeObject:self.zipCode forKey:@"zipCode"];
//    [encoder encodeObject:self.countryId forKey:@"countryId"];
//    [encoder encodeObject:self.contactNumber forKey:@"contactNumber"];
//    [encoder encodeObject:self.firstlineaddress forKey:@"firstlineaddress"];
//    [encoder encodeObject:self.secondlineaddress forKey:@"secondlineaddress"];
//}

@end
