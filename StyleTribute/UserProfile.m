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
    UserProfile* profile = [UserProfile new];
    
    profile.isActive = [[self class] parseBool:@"is_active" fromDict:dict];
    profile.entity_id = [[self class] parseString:@"entity_id" fromDict:dict];
    profile.email = [[self class] parseString:@"email" fromDict:dict];
    profile.phone = [[self class] parseString:@"phone" fromDict:dict];
    profile.gender = [[self class] parseString:@"gender" fromDict:dict];
    profile.country = [[self class] parseString:@"country" fromDict:dict];
    profile.userName = [[self class] parseString:@"nickname" fromDict:dict];
    profile.firstName = [[self class] parseString:@"firstname" fromDict:dict];
    profile.lastName = [[self class] parseString:@"lastname" fromDict:dict];
    
    NSDictionary* shippingDict = [dict objectForKey:@"shipping"];
    if(shippingDict && ![shippingDict isKindOfClass:[NSNumber class]]) {
        profile.shippingAddress = [Address parseFromJson:shippingDict];
    }
    
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
    if(self.firstName.length > 0 && self.lastName.length > 0 && self.phone.length > 0) {
        return YES;
    } else {
        return NO;
    }
}   

@end
