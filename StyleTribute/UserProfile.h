//
//  UserProfile.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 25/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface UserProfile : BaseModel

+(instancetype)parseFromJson:(NSDictionary*)dict;

@property BOOL isActive;
@property NSString* email;
@property NSString* phone;
@property NSString* gender;
@property NSString* country;

@end
