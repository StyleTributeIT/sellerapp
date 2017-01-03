//
//  UserProfile.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 25/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"
#import "Address.h"

@interface UserProfile : BaseModel

@property BOOL isActive;
@property NSString* entity_id;
@property NSString* email;
@property NSString* phone;
@property NSString* gender;
@property NSString* country;
@property NSString* firstName;
@property NSString* lastName;
@property NSString* userName;
@property Address* shippingAddress;

+(instancetype)parseFromJson:(NSDictionary*)dict;
+(instancetype)parseFromFBJson:(NSDictionary*)dict;

-(BOOL)isFilled;

@end
