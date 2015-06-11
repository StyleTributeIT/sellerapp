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
    NSNumber* val = [dict objectForKey:param];
    if(val) {
        return [val boolValue];
    } else {
        return NO;
    }
}

+(NSString*)parseString:(NSString*)param fromDict:(NSDictionary*)dict {
    NSString* val = [dict objectForKey:param];
    if(val == nil || ![val isKindOfClass:[NSString class]] || [val isEqualToString:@"<null>"]) {
        return @"";
    } else {
        return val;
    }
}

+(BOOL)parseUInteger:(NSString*)param fromDict:(NSDictionary*)dict {
    NSNumber* val = [dict objectForKey:param];
    if(val) {
        return [val unsignedIntegerValue];
    } else {
        return 0;
    }
}

@end
