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
#import "UserProfile.h"

typedef void (^JSONRespAccount)(UserProfile* profile);
typedef void (^JSONRespLogout)();
typedef void (^JSONRespArray)(NSArray* products);
typedef void (^JSONRespError)(NSString* error);

@interface ApiRequester : NSObject

+(ApiRequester*)sharedInstance;

-(AFHTTPRequestOperation*)registerWithEmail:(NSString*)email
                                   password:(NSString*)password
                                  firstName:(NSString*)firstName
                                   lastName:(NSString*)lastName
                                   userName:(NSString*)userName
                                    country:(NSString*)country
                                      phone:(NSString*)phone
                                    success:(JSONRespAccount)success
                                    failure:(JSONRespError)failure;

-(AFHTTPRequestOperation*)loginWithEmail:(NSString*)email andPassword:(NSString*)password success:(JSONRespAccount)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)logoutWithSuccess:(JSONRespLogout)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getProductsWithSuccess:(JSONRespArray)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getAccountWithSuccess:(JSONRespAccount)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getCountries:(JSONRespArray)success failure:(JSONRespError)failure;

@end
