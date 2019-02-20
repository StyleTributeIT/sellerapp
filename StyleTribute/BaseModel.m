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
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        NSNumber* val = [dict objectForKey:param];
        if(val) {
            return [val boolValue];
        } else {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

+(NSString*)parseString:(NSString*)param fromDict:(NSDictionary*)dict {
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        int a = [dict objectForKey:param];
        NSString* val = [dict objectForKey:param];
        if(val == nil || ![val isKindOfClass:[NSString class]] || [val isEqualToString:@"<null>"]) {
            return nil;
        } else {
            return val;
        }
    }
    else
    {
        return nil;
    }
}

+(long)parseInt:(NSString*)param fromDict:(NSDictionary*)dict {
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        NSNumber* val = [dict objectForKey:param];
        if(!val)
        {
            return [val intValue];
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

+(BOOL)parseUInteger:(NSString*)param fromDict:(NSDictionary*)dict {
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        NSNumber* val = [dict objectForKey:param];
        if(val) {
            return [val unsignedIntegerValue];
        } else {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

+(long)parseLong:(NSString*)param fromDict:(NSDictionary*)dict {
    
    if ([dict isKindOfClass:[NSDictionary class]])
    {
        NSNumber* val = [dict objectForKey:param];
        if(val) {
            NSLog(@"%ld",[val longValue]);
            return [val longValue];
            
        } else {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

+(NSString*)validatedString:(NSString*)val {
	if(val == nil || ![val isKindOfClass:[NSString class]] || [val isEqualToString:@"<null>"]) {
		return nil;
	} else {
		return val;
	}
}

+(float)parseFloat:(NSString*)param fromDict:(NSDictionary*)dict {
        NSNumber* val = [dict objectForKey:param];
//    int returnval;
//    if ([val isKindOfClass:[NSNull null]] || [val isEqual:0]) {
//         returnval = 0;
//    } else {
//       returnval = val;
//    }
    if(!val) {
        return [val floatValue];
    } else {
        return 0;
    }
}

@end
