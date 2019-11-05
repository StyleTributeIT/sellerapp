//
//  NotificationBody.h
//  StyleTribute
//
//  Created by Alankar Muley on 05/11/19.
//  Copyright © 2019 StyleTribute. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModel.h"

@interface NotificationBody : BaseModel

@property NSString* type;
@property NSString* title;
@property NSString* message;
@property NSString* picture;
+(instancetype)parseFromJson:(NSDictionary*)dict;
@end
