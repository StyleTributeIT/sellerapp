//
//  ApiRequester.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "GlobalDefs.h"
#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import <AFHTTPRequestOperation.h>

typedef void (^JSONRespProducts)(NSArray* products);
typedef void (^JSONRespError)(NSString* error);

@interface ApiRequester : NSObject

+(ApiRequester*)sharedInstance;

-(AFHTTPRequestOperation*)getProductsWithSuccess:(JSONRespProducts)success failure:(JSONRespError)failure;

@end
