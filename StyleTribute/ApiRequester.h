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
#import "BankAccount.h"

typedef void (^JSONRespAccount)(UserProfile* profile);
typedef void (^JSONRespBankAccount)(BankAccount* profile);
typedef void (^JSONRespEmpty)();
typedef void (^JSONRespArray)(NSArray* products);
typedef void (^JSONRespError)(NSString* error);
typedef void (^JSONRespFBLogin)(BOOL loggedIn, UserProfile* fbProfile);

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
-(AFHTTPRequestOperation*)loginWithFBToken:(NSString*)fbToken success:(JSONRespFBLogin)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)logoutWithSuccess:(JSONRespEmpty)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getProductsWithSuccess:(JSONRespArray)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getAccountWithSuccess:(JSONRespAccount)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getCountries:(JSONRespArray)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getCategories:(JSONRespArray)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getProducts:(JSONRespArray)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)setDeviceToken:(NSString*)token success:(JSONRespEmpty)success failure:(JSONRespError)failure;
-(AFHTTPRequestOperation*)getBankAccount:(JSONRespBankAccount)success failure:(JSONRespError)failure;

-(AFHTTPRequestOperation*)setBankAccountWithBankName:(NSString*)bankName
                                            bankCode:(NSString*)bankCode
                                         beneficiary:(NSString*)beneficiary
                                       accountNumber:(NSString*)accountNumber
                                          branchCode:(NSString*)branchCode
                                             success:(JSONRespEmpty)success
                                             failure:(JSONRespError)failure;

@end
