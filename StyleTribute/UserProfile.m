//
//  UserProfile.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 25/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile

-(instancetype)init {
    self = [super init];
    if(self) {
		self.shippingAddress = nil;
    }
    return self;
}

+(instancetype)parseFromJson:(NSDictionary*)dict {
    
    NSDictionary *dicttemp = [[dict valueForKey:@"customer"] valueForKey:@"data"];
    UserProfile* profile = [UserProfile new];
    
    profile.isActive = [[self class] parseBool:@"is_active" fromDict:dicttemp];
    profile.entity_id = [[self class] parseString:@"entity_id" fromDict:dicttemp];
    profile.email = [[self class] parseString:@"email" fromDict:dict];
    profile.phone = [[self class] parseString:@"phone" fromDict:dicttemp];
    profile.gender = [[self class] parseString:@"gender" fromDict:dicttemp];
    profile.country = [[self class] parseString:@"country" fromDict:dicttemp];
    profile.userName = [[self class] parseString:@"nickname" fromDict:dicttemp];
    profile.firstName = [[self class] parseString:@"first_name" fromDict:dicttemp];
    profile.lastName = [[self class] parseString:@"last_name" fromDict:dicttemp];
    
    
    
    return profile;
}

+(instancetype)parseFromFBJson:(NSDictionary*)dict {
    UserProfile* profile = [UserProfile new];
    
    profile.email = [[self class] parseString:@"email" fromDict:dict];
    profile.firstName = [[self class] parseString:@"first_name" fromDict:dict];
    profile.lastName = [[self class] parseString:@"last_name" fromDict:dict];
    
    return profile;
}

-(BOOL)isFilled {
    if(self.firstName.length > 0 && self.lastName.length > 0) {
        return YES;
    } else {
        return NO;
    }
}   

@end
