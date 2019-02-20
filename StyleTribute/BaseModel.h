//
//  BaseModel.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 25/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

+(BOOL)parseBool:(NSString*)param fromDict:(NSDictionary*)dict;
+(NSString*)parseString:(NSString*)param fromDict:(NSDictionary*)dict;
+(long)parseInt:(NSString*)param fromDict:(NSDictionary*)dict;
+(BOOL)parseUInteger:(NSString*)param fromDict:(NSDictionary*)dict;
+(long)parseLong:(NSString*)param fromDict:(NSDictionary*)dict;
+(float)parseFloat:(NSString*)param fromDict:(NSDictionary*)dict;

+(NSString*)validatedString:(NSString*)val;
@end
