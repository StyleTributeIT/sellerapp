//
//  BaseModel.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 25/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

+(BOOL)parseBool:(NSString*)param fromDict:(NSDictionary*)dict {
    return [[dict objectForKey:param] boolValue];
}

+(NSString*)parseString:(NSString*)param fromDict:(NSDictionary*)dict {
    NSString* val = [dict objectForKey:param];
    if(val == nil || [val isKindOfClass:[NSNull class]] || [val isEqualToString:@"<null>"]) {
        return @"";
    } else {
        return val;
    }
}

@end
