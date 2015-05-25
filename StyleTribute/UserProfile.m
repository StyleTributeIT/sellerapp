//
//  UserProfile.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 25/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile

+(instancetype)parseFromJson:(NSDictionary*)dict {
    UserProfile* profile = [UserProfile new];
    
    profile.isActive = [[self class] parseBool:@"is_active" fromDict:dict];
    profile.email = [[self class] parseString:@"email" fromDict:dict];
    profile.phone = [[self class] parseString:@"phone" fromDict:dict];
    profile.gender = [[self class] parseString:@"gender" fromDict:dict];
    profile.country = [[self class] parseString:@"country" fromDict:dict];
    
    return profile;
}

@end
