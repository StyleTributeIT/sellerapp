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
#import "Product.h"

typedef void (^JSONRespAccount)(UserProfile* profile);
typedef void (^JSONRespBankAccount)(BankAccount* profile);
typedef void (^JSONRespEmpty)();
typedef void (^JSONRespArray)(NSArray* products);
typedef void (^JSONRespError)(NSString* error);
typedef void (^JSONRespFBLogin)(BOOL loggedIn, UserProfile* fbProfile);
typedef void (^JSONRespId)(NSUInteger identifier);
typedef void (^JSONRespProgress)(float progress);
typedef void (^JSONRespProduct)(Product* product);

@interface ApiRequester : NSObject

+(ApiRequester*)sharedInstance;

-(void)registerWithEmail:(NSString*)email
                                   password:(NSString*)password
                                  firstName:(NSString*)firstName
                                   lastName:(NSString*)lastName
                                   userName:(NSString*)userName
                                    country:(NSString*)country
                                      phone:(NSString*)phone
                                    success:(JSONRespAccount)success
                                    failure:(JSONRespError)failure;

-(void)loginWithEmail:(NSString*)email andPassword:(NSString*)password success:(JSONRespAccount)success failure:(JSONRespError)failure;
-(void)loginWithFBToken:(NSString*)fbToken success:(JSONRespFBLogin)success failure:(JSONRespError)failure;
-(void)logoutWithSuccess:(JSONRespEmpty)success failure:(JSONRespError)failure;
-(void)getAccountWithSuccess:(JSONRespAccount)success failure:(JSONRespError)failure;
-(void)getCountries:(JSONRespArray)success failure:(JSONRespError)failure;
-(void)getCategories:(JSONRespArray)success failure:(JSONRespError)failure;
-(void)getProducts:(JSONRespArray)success failure:(JSONRespError)failure;
-(void)setDeviceToken:(NSString*)token success:(JSONRespEmpty)success failure:(JSONRespError)failure;
-(void)getBankAccount:(JSONRespBankAccount)success failure:(JSONRespError)failure;

-(void)setBankAccountWithBankName:(NSString*)bankName
                                            bankCode:(NSString*)bankCode
                                         beneficiary:(NSString*)beneficiary
                                       accountNumber:(NSString*)accountNumber
                                          branchCode:(NSString*)branchCode
                                             success:(JSONRespEmpty)success
                                             failure:(JSONRespError)failure;

-(void)getDesigners:(JSONRespArray)success failure:(JSONRespError)failure;
-(void)getConditions:(JSONRespArray)success failure:(JSONRespError)failure;

-(void)setAccountWithUserName:(NSString*)username
                    firstName:(NSString*)firstName
                     lastName:(NSString*)lastName
                      country:(NSString*)country
                        phone:(NSString*)phone
                      success:(JSONRespEmpty)success
                      failure:(JSONRespError)failure;

-(void)setProductWithId:(NSUInteger)identifier
                   name:(NSString*)name
            description:(NSString*)description
              shortDesc:(NSString*)shortDesc
                  price:(float)price
               category:(NSUInteger)categoryId
              condition:(NSUInteger)conditionId
               designer:(NSUInteger)designerId
                success:(JSONRespProduct)success
                failure:(JSONRespError)failure;

-(void)uploadImage:(UIImage*)image ofType:(NSString*)type toProduct:(NSUInteger)productId success:(JSONRespEmpty)success failure:(JSONRespError)failure progress:(JSONRespProgress)progress;
-(void)deleteImage:(NSUInteger)imageId fromProduct:(NSUInteger)productId success:(JSONRespEmpty)success failure:(JSONRespError)failure;
-(void)setProcessStatus:(NSString*)status forProduct:(NSUInteger)productId success:(JSONRespProduct)success failure:(JSONRespError)failure;

@end
