//
//  Designer.m
//  StyleTribute
//
//  Created by selim mustafaev on 23/06/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Designer.h"

@interface Designer () <NSCoding>

@end

@implementation Designer

+(instancetype)parseFromJson:(NSDictionary*)dict; {
    Designer* designer = [Designer new];
    
    designer.identifier = [[self class] parseString:@"id" fromDict:dict];
    designer.name = [[self class] parseString:@"name" fromDict:dict];
    
    return designer;
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
