//
//  Notification.m
//  StyleTribute
//
//  Created by Alankar Muley on 04/11/19.
//  Copyright © 2019 StyleTribute. All rights reserved.
//

#import "Notification.h"

@implementation Notification

+(instancetype)parseFromJson:(NSDictionary*)dict {
   // NSLog(@"%@",dict);
    
    Notification *item = [self new];
    @try {
        item.notification_id =  [[dict valueForKey:@"id"] integerValue];
        item.message_id = [self parseString:@"message_id" fromDict:dict];
        item.from = [self parseString:@"from" fromDict:dict];
        item.recipient = [self parseString:@"recipient" fromDict:dict];
        item.subject = [self parseString:@"subject" fromDict:dict];
        item.body = [self parseString:@"body" fromDict:dict];
        item.sent_date = [self parseString:@"sent_date" fromDict:dict];
        item.paramTry = (NSUInteger)[[self parseString:@"try" fromDict:dict] integerValue];
        item.last_try = [self parseString:@"last_try" fromDict:dict];
        item.delivered = [self parseString:@"delivered" fromDict:dict];
        item.read = [self parseString:@"read" fromDict:dict];

        item.createdAt =  [self parseString:@"createdAt" fromDict:dict];
        item.updatedAt = [self parseString:@"updatedAt" fromDict:dict];
    }@catch (NSException *exception) {
    }
    @finally {
        NSLog(@"Finally condition");
    }
   
    
    return item;
}
@end
