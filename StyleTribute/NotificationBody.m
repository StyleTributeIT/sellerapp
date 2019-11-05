//
//  NotificationBody.m
//  StyleTribute
//
//  Created by Alankar Muley on 05/11/19.
//  Copyright © 2019 StyleTribute. All rights reserved.
//

#import "NotificationBody.h"

@implementation NotificationBody

+(instancetype)parseFromJson:(NSDictionary*)dict {
      NotificationBody *item = [self new];
    @try {
        item.type = [self parseString:@"type" fromDict:dict];
        item.title = [self parseString:@"title" fromDict:dict];
        item.message = [self parseString:@"message" fromDict:dict];
        item.picture = [self parseString:@"picture" fromDict:dict];
    }@catch (NSException *exception) {
    }
    @finally {
        NSLog(@"Finally condition");
    }
  
    return item;
}

@end
