//
//  Address.h
//  StyleTribute
//
//  Created by selim mustafaev on 16/09/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"
#import "NamedItems.h"
#import "Country.h"

@interface Address : BaseModel

@property NSString* firstName;
@property NSString* cusomer_id;
@property NSString* lastName;
@property NSString* company;
@property NSString* address;
@property NSString* city;
@property NamedItem* state;
@property NSString* zipCode;
@property NSString* countryId;
@property NSString* contactNumber;
@property NSString* firstlineaddress;
@property NSString* secondlineaddress;


+(instancetype)parseFromJson:(NSDictionary*)dict;

@end
