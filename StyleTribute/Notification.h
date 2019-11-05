//
//  Notification.h
//  StyleTribute
//
//  Created by Alankar Muley on 04/11/19.
//  Copyright © 2019 StyleTribute. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"


@interface Notification : BaseModel<NSCoding,NSCopying>

@property NSUInteger* notification_id;
@property NSString* message_id;
@property NSString* from;
@property NSString* recipient;
@property NSString* subject;
@property NSString* body;
@property NSString* sent_date;
@property NSUInteger* paramTry;
@property NSString* last_try;
@property NSString* delivered;
@property NSString* read;
@property NSString* createdAt;
@property NSString* updatedAt;

+(instancetype)parseFromJson:(NSDictionary*)dict;
@end
