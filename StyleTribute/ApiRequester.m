//
//  ApiRequester.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ApiRequester.h"
#import "Product.h"
#import <Reachability.h>
#import "UserProfile.h"
#import "Country.h"
#import "Category.h"
#import "DataCache.h"
#import "Photo.h"
#import "NamedItems.h"
#import <FBSDKLoginKit/FBSDKLoginManager.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginManagerLoginResult.h>
#import "Address.h"

static NSString *const boundary = @"0Xvdfegrdf876fRD";

@interface ApiRequester ()

@property AFHTTPSessionManager* sessionManager;
@property AFHTTPRequestOperationManager *requsetOperationManager;

@end

@implementation ApiRequester

#pragma mark - Helper methods

+(ApiRequester*)sharedInstance
{
    static dispatch_once_t once;
    static ApiRequester *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[ApiRequester alloc] init];
        sharedInstance.requsetOperationManager = [AFHTTPRequestOperationManager manager];
        sharedInstance.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:DefApiHost]];
        AFJSONResponseSerializer* serializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        serializer.removesKeysWithNullValues = YES;
        sharedInstance.sessionManager.responseSerializer = serializer;
        sharedInstance.sessionManager.requestSerializer.timeoutInterval = 3600;
        
        NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
        NSString* apiToken = [defs stringForKey:@"apiToken"];
        if(apiToken) {
            [sharedInstance.sessionManager.requestSerializer setValue:apiToken forHTTPHeaderField:@"X-Auth-Token"];
        }
        
    });
    return sharedInstance;
}

-(BOOL)checkInternetConnectionWithErrCallback:(JSONRespError)errCallback {
    if(![Reachability reachabilityForInternetConnection].isReachable) {
        NSLog(@"internet connection problem");
        errCallback(DefInternetUnavailableMsg);
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)checkSuccessForResponse:(NSDictionary*)resp errCalback:(JSONRespError)errCallback {
    if(!resp) {
        errCallback(DefGeneralErrMsg);
        return NO;
    }
    NSLog(@"resp : %@", resp);

    if([[resp objectForKey:@"success"] boolValue]) {
        return YES;
    } else {
        NSString* error = [resp objectForKey:@"error"];
        if(!error) {
            error = DefGeneralErrMsg;
        }
        
        NSLog(@"checkSuccessForResponse error: %@", error);
        errCallback(error);
        
        return NO;
    }
}

-(void)logError:(NSError*)error withCaption:(NSString*)caption {
    
    if(error != nil && error.userInfo != nil) {
        for(id key in error.userInfo) {
            id val = [error.userInfo objectForKey:key];
            if([val isKindOfClass:[NSData class]]) {
                val = [[NSString alloc] initWithData:val encoding:NSUTF8StringEncoding];
            }
            
            NSLog(@"%@: %@", key, val);
        }
    }
}

#pragma mark - API methods

-(void)registerWithEmail:(NSString*)email
                                   password:(NSString*)password
                                  firstName:(NSString*)firstName
                                   lastName:(NSString*)lastName
                                   userName:(NSString*)userName
                                    country:(NSString*)country
                                      phone:(NSString*)phone
                                    success:(JSONRespAccount)success
                                    failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSDictionary* params = @{@"email":email, @"password":password, @"firstName": firstName, @"lastName": lastName};
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/auth/register", DefApiHost];
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonBodyData];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                long l = (long)[httpResponse statusCode];
                                                if (l == 200)
                                                {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    success([UserProfile parseFromJson:[forJSONObject objectForKey:@"model"]]);
                                                }else {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    failure([forJSONObject valueForKey:@"message"]);
                                                }
                                                
                                            }];
    [task resume];
}

-(void)loginWithEmail:(NSString*)email andPassword:(NSString*)password success:(JSONRespAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/auth/login", DefApiHost];
     NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:email,@"email",password,@"password", nil];
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonBodyData];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                
                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    long l = (long)[httpResponse statusCode];
                    if (l == 200)
                    {
                            NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                            NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
                            [pref setValue:[[forJSONObject valueForKey:@"data"] valueForKey:@"access_token"] forKey:@"Token"];
                           [pref synchronize];
                        success([UserProfile parseFromJson:[[[forJSONObject objectForKey:@"data"]valueForKey:@"customer"]valueForKey:@"data"]]);
                    }else {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        failure([forJSONObject valueForKey:@"message"]);
                    }
                                                
                }];
    [task resume];
}

-(void)getAccountWithSuccess:(JSONRespAccount)success failure:(JSONRespError)failure {
    
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSString *token = @"";
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"Token"] == nil)
    {
        
    }
    else
    {
        token =  [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    }
    
    NSLog(@"%@",token);
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/users/me", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    long l = (long)[httpResponse statusCode];
                    if (l == 200)
                    {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSLog(@"%@",forJSONObject);
                         [DataCache sharedInstance].userProfile = [UserProfile parseFromJson:[forJSONObject objectForKey:@"data"]];
                         NSUserDefaults *userdefauls = [NSUserDefaults standardUserDefaults];
                        [userdefauls setValue:[[[[forJSONObject objectForKey:@"data"]valueForKey:@"customer"]valueForKey:@"data"]valueForKey:@"id"] forKey:@"cust_id"];
                        [userdefauls synchronize];
                    
                        NSDictionary *dicttme = [[[[[[forJSONObject valueForKey:@"data"] valueForKey:@"customer"] valueForKey:@"data"] valueForKey:@"default_payment_detail"] valueForKey:@"data"] valueForKey:@"data"];
                        
                        
                        NSArray* shippingDict = [[dicttme objectForKey:@"addresses"] valueForKey:@"data"];
                        if (shippingDict != nil || shippingDict.count != 0)
                        {
                            NSDictionary *dictdata = [shippingDict lastObject];
                            [DataCache sharedInstance].shippingAddress = [Address parseFromJson:dictdata];
                        }
                        
                        
                       
                        [DataCache sharedInstance].bankAccount = [BankAccount parseFromJson:dicttme];
                        [DataCache sharedInstance].userProfile = [UserProfile parseFromJson:[forJSONObject objectForKey:@"data"]];
                        NSDictionary *dicttemp = [[[forJSONObject valueForKey:@"data"] valueForKey:@"customer"] valueForKey:@"data"];
                        
                        NSArray* shippingDict1 = [[dicttemp objectForKey:@"addresses"] valueForKey:@"data"];
                        if (shippingDict1 != nil || shippingDict1.count != 0)
                        {
                            NSDictionary *dictdata = [shippingDict1 lastObject];
                             [DataCache sharedInstance].shippingAddress = [Address parseFromJson:dictdata];
                        }
                        success([UserProfile parseFromJson:[forJSONObject objectForKey:@"data"]]);
                    }else {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        failure([forJSONObject valueForKey:@"message"]);
                    }
                }];
    [task resume];
}


-(void)changeuserprofile:(NSString*)first_name andPassword:(NSString*)last_name success:(JSONRespAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:first_name,@"first_name",last_name,@"last_name", nil];
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSLog(@"%@",token);
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/users/me", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"PUT";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonBodyData];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                        long l = (long)[httpResponse statusCode];
                        if (l == 200)
                        {
                            NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                            NSUserDefaults *userdefauls = [NSUserDefaults standardUserDefaults];
                            [userdefauls setValue:[[[[forJSONObject objectForKey:@"data"]valueForKey:@"customer"]valueForKey:@"data"]valueForKey:@"id"] forKey:@"cust_id"];
                            [userdefauls synchronize];
                            [DataCache sharedInstance].userProfile = [UserProfile parseFromJson:[forJSONObject objectForKey:@"data"]];
                            NSDictionary *dicttemp = [[[forJSONObject valueForKey:@"data"] valueForKey:@"customer"] valueForKey:@"data"];
                            NSDictionary* shippingDict = [[dicttemp objectForKey:@"addresses"] valueForKey:@"data"];
                            [DataCache sharedInstance].shippingAddress = [Address parseFromJson:shippingDict];
                            success([UserProfile parseFromJson:[forJSONObject objectForKey:@"data"]]);
                        }else {
                            NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                            failure([forJSONObject valueForKey:@"message"]);
                        }
                                                
                }];
    [task resume];
}




-(void)loginWithFBToken:(NSString*)fbToken success:(JSONRespFBLogin)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager POST:@"authorizeFb" parameters:@{@"token":fbToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            UserProfile* profile = nil;
            BOOL isLoggedIn = [[responseObject objectForKey:@"loggedIn"] boolValue];
            if(isLoggedIn) {
                NSString* token = [responseObject objectForKey:@"token"];
                [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"X-Auth-Token"];
                NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
                [defs setObject:token forKey:@"apiToken"];
                [defs synchronize];
                profile = [UserProfile parseFromJson:[responseObject objectForKey:@"model"]];
            } else {
                profile = [UserProfile parseFromFBJson:[responseObject objectForKey:@"fb"]];
            }
            
            success(isLoggedIn, profile);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"FB login error"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)logoutWithSuccess:(JSONRespEmpty)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"invalidate" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"X-Auth-Token"];
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            [defs removeObjectForKey:@"apiToken"];
            [DataCache sharedInstance].products = nil;
            [DataCache sharedInstance].userProfile = nil;
            [defs synchronize];
            if ([FBSDKAccessToken currentAccessToken])
            {
                
                FBSDKLoginManager *manager = [[FBSDKLoginManager alloc] init];
                [manager logOut];
            }
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"logout error"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)getCountries:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/countries", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                long l = (long)[httpResponse statusCode];
                if (l == 200)
                {
                      NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                      NSLog(@"One of these might exist - object: %@", forJSONObject);
                                                    
                        NSMutableArray* countries = [NSMutableArray new];
                        for (NSDictionary* countryDict in [forJSONObject valueForKey:@"data"]) {
                        [countries addObject:[Country parseFromJson:countryDict]];
                        }
                    NSLog(@"%@",countries);
                    success(countries);
                }else {
                    failure(DefGeneralErrMsg);
                }
          }];
    [task resume];
}

-(void)getSubCategories:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"filterOptions" parameters:@{@"category_id":@"4"} success:^(NSURLSessionDataTask *task, NSArray* responseObject) {
        NSMutableArray* categories = [NSMutableArray new];
        for (NSDictionary* categoryDict in responseObject) {
            [categories addObject:[STCategory parseFromJson:categoryDict]];
        }
        success(categories);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"getCategories error"];
        failure(DefGeneralErrMsg);
    }];
}



-(void)getCategories:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
 
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/categories/list/outlines", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    long l = (long)[httpResponse statusCode];
                    if (l == 200)
                    {
                         NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSMutableArray* categories = [NSMutableArray new];
                        for (NSDictionary* categoryDict in [forJSONObject valueForKey:@"data"]) {
                                    [categories addObject:[STCategory parseFromJson:categoryDict]];
                            }
                        success(categories);
                        
                    }else {
                        failure(DefGeneralErrMsg);
                    }
                }];
    [task resume];
}

-(void)getProducts:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/products?page=1&per_page=20", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                        long l = (long)[httpResponse statusCode];
                        if (l == 200)
                        {
                            NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                           NSMutableArray* products = [NSMutableArray new];
                            for (NSDictionary* productDict in [forJSONObject valueForKey:@"data"]) {
                            Product* product = [Product parseFromJson:productDict];
                            [products addObject:product];
                            }
                             success(products);
                       
                    }else {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSLog(@"%@",forJSONObject);
                        failure([forJSONObject valueForKey:@"message"]);
                    }
                                                
                }];
    [task resume];
}


-(void)setDeviceToken:(NSString*)token success:(JSONRespEmpty)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager POST:@"deviceToken" parameters:@{@"deviceToken":token} success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"setDeviceToken error"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)getBankAccount:(JSONRespBankAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"seller/bankAccount" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success([BankAccount parseFromJson:responseObject]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"getBankAccount error"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)setBankAccountWithBankName:(NSString*)bankName
                                            bankCode:(NSString*)bankCode
                                         beneficiary:(NSString*)beneficiary
                                       accountNumber:(NSString*)accountNumber
                                          branchCode:(NSString*)branchCode
                                             success:(JSONRespEmpty)success
                                             failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSDictionary* params = @{@"bankname":bankName, @"bankcode":bankCode, @"bankbeneficiary":beneficiary, @"bankaccountnumber":accountNumber, @"bankbranchcode":branchCode,@"payment_method_name": @"TRANSFER"};
    NSLog(@"%@",params);
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/users/me/payment-detail", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonBodyData];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                long l = (long)[httpResponse statusCode];
                                                if (l == 200)
                                                {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                
                                                    NSDictionary *dicttme = [[[[[[forJSONObject valueForKey:@"data"] valueForKey:@"customer"] valueForKey:@"data"] valueForKey:@"default_payment_detail"] valueForKey:@"data"] valueForKey:@"data"];
                                                    
                                                    [DataCache sharedInstance].bankAccount = [BankAccount parseFromJson:dicttme];
                                                    success();
                                                }else {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    failure([forJSONObject valueForKey:@"message"]);
                                                }
                                                
                                            }];
    [task resume];
}

-(void)getDesigners:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/designers/list", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                    long l = (long)[httpResponse statusCode];
                    if (l == 200)
                    {
                            NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSMutableArray* designers = [NSMutableArray new];
                        for (NSDictionary* designerDict in [forJSONObject valueForKey:@"data"]) {
                            [designers addObject:[NamedItem parseFromJson:designerDict]];
                        }
                        success(designers);
                    }else {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        failure([forJSONObject valueForKey:@"message"]);
                    }
                                                
                }];
    [task resume];
    
}

-(void)getConditions:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/conditions/list", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                         NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                         long l = (long)[httpResponse statusCode];
                         if (l == 200)
                         {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        NSLog(@"One of these might exist - object: %@", forJSONObject);
                        NSMutableArray* conditions = [NSMutableArray new];
                        for (NSDictionary* conditionDict in [forJSONObject valueForKey:@"data"]) {
                            NSLog(@"%@",conditionDict);
                            [conditions addObject:[NamedItem parseFromJson:conditionDict]];
                        }
                        success(conditions);
                    }else {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        failure([forJSONObject valueForKey:@"message"]);
                    }
                                                
                }];
    [task resume];

}

-(void)setAccountWithUserName:(NSString*)userName
                    firstName:(NSString*)firstName
                     lastName:(NSString*)lastName
                      country:(NSString*)country
                        phone:(NSString*)phone
                      success:(JSONRespEmpty)success
                      failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:@{@"first_name":firstName,@"last_name":lastName} options:kNilOptions error:nil];
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/users/me", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"PUT";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonBodyData];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                            long l = (long)[httpResponse statusCode];
                            if (l == 200)
                            {
                                NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                 NSUserDefaults *userdefauls = [NSUserDefaults standardUserDefaults];
                                [userdefauls setValue:[[[[forJSONObject objectForKey:@"data"]valueForKey:@"customer"]valueForKey:@"data"]valueForKey:@"id"] forKey:@"cust_id"];
                                [userdefauls synchronize];
                                [DataCache sharedInstance].userProfile = [UserProfile parseFromJson:[forJSONObject objectForKey:@"data"]];
                                NSDictionary *dicttemp = [[[forJSONObject valueForKey:@"data"] valueForKey:@"customer"] valueForKey:@"data"];
                                NSDictionary* shippingDict = [[dicttemp objectForKey:@"addresses"] valueForKey:@"data"];
                                [DataCache sharedInstance].shippingAddress = [Address parseFromJson:shippingDict];
                                
                                success([UserProfile parseFromJson:[forJSONObject objectForKey:@"data"]]);
                         }else {
                            NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                            failure([forJSONObject valueForKey:@"message"]);
                         }
                    }];
    [task resume];
    
    
    
    
    

    if(![self checkInternetConnectionWithErrCallback:failure]) return;

    NSMutableDictionary* params = [@{/* @"userName":userName, */ @"firstName": firstName, @"lastName": lastName, /* @"country": country, */} mutableCopy];
    if(phone != nil && ![phone isKindOfClass:[NSNull class]]) {
        [params setObject:phone forKey:@"phone"];
    }

    [self.sessionManager POST:@"seller/account" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"setAccount error"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)setProduct:(Product*)product Tag:(BOOL)setProduct success:(JSONRespProduct)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSString *method;
    NSMutableDictionary* params;
    NSString* urlString1;
    if (setProduct == true)
    {
        NSMutableArray *arr = [[NSMutableArray alloc]init];
        NSString *number = [NSString stringWithFormat:@"%d", product.category.idNum];
        [arr addObject:number];
         urlString1 = [NSString stringWithFormat:@"%@api/v1/products", DefApiHost];
        params = [@{@"name": product.name,
                    @"description": product.descriptionText,
                    @"condition": @(product.condition.identifier),
                    @"designer_id": @(product.designer.identifier),
                    @"fix_payout_amount": @(product.price),
                    @"original_price": @(product.originalPrice),
                    @"size":@"88",
                    @"categories":arr,
                    @"partner_sku" :@"",
                    @"process_type_code":@"DIY",
                    @"provider_code":@"SG",@"color":@"5"} mutableCopy];
        method = @"POST";
    }else
    {
        method = @"PUT";
        urlString1 = [NSString stringWithFormat:@"%@api/v1/products/%d", DefApiHost, product.identifier];
        params = [@{@"name": product.name,
                    @"description": product.descriptionText,
                    @"condition_id": @(product.condition.identifier),
                    @"original_price": @(product.originalPrice),
                    @"price": @(product.price)} mutableCopy];
      
        if (product.other_designer != nil)
        {
            [params setObject:product.other_designer.name forKey:@"other_designer"];
        } else {
            [params setValue:@(product.designer.identifier) forKey:@"designer_id"];
        }
        
        NSString* firstSize = [product.category.sizeFields firstObject];
        if ([firstSize isEqualToString:@"kidzsize"] || [firstSize isEqualToString:@"kidzshoes"])
        {
            [params setObject:product.kidzsize forKey:firstSize];
        } else
            if([firstSize isEqualToString:@"size"]) {
                [params setObject:@[product.unit, product.size] forKey:@"size"];
            }else if([firstSize isEqualToString:@"dimensions"] && product.dimensions) {
                NSString* width = [product.dimensions objectAtIndex:0];
                NSString* height = [product.dimensions objectAtIndex:1];
                NSString* depth = [product.dimensions objectAtIndex:2];
                
                if(width)
                    [params setObject:width forKey:@"dimensions[width]"];
                if(height)
                    [params setObject:height forKey:@"dimensions[height]"];
                if(depth)
                    [params setObject:depth forKey:@"dimensions[depth]"];
            }
        /*
         else if([firstSize isEqualToString:@"shoesize"]) {
         [params setObject:@(product.shoeSize.identifier) forKey:@"shoesize"];
         if(product.heelHeight)
         [params setObject:product.heelHeight forKey:@"heel_height"];
         }
         */
        if(product.identifier > 0) {
            [params setObject:@(product.identifier) forKey:@"id"];
        }
        if(product.processStatus.length > 0) {
            [params setObject:product.processStatus forKey:@"process_status"];
        }
        
    }
     NSLog(@"%@",params);
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
  
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = method;
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonBodyData];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                long l = (long)[httpResponse statusCode];
                                                if (l == 200)
                                                {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    NSDictionary* productDict = [forJSONObject objectForKey:@"product"];
                                                    Product* product = [Product parseFromJson:productDict];
                                                    success(product);
                                                    
                                                    
                                                }else {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    failure([forJSONObject valueForKey:@"message"]);
                                                }
                                            }];
    [task resume];
}

-(void)uploadImage:(UIImage*)image ofType:(NSString*)type toProduct:(NSUInteger)productId success:(JSONRespEmpty)success failure:(JSONRespError)failure progress:(JSONRespProgress)progress {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    NSLog(@"%@",imageData);
      NSLog(@"%@",type);
     NSString* url = [NSString stringWithFormat:@"%@api/v1/products/%d/pictures", DefApiHost, productId];
    NSDictionary* params = @{@"label": @"hans",@"order":@"1",@"main":@"true"};
    @try
    {
        NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        NSDictionary *param = params;
        AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
        [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [requestSerializer setValue:token forHTTPHeaderField:@"Authorization"];
        manager.requestSerializer=requestSerializer;
        [manager.requestSerializer setTimeoutInterval:150];
        [self.sessionManager setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            progress(1.0*totalBytesSent/totalBytesExpectedToSend);
        }];
        [manager POST:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
         {
             [formData appendPartWithFileData:imageData name:@"files" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
             
         } success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             NSLog(@"response %@" , operation.responseString);
             success();
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
            failure(operation.responseString);
         }];
        
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"WebserviceDataProvider sendRequestToServerWithFile exception %@",exception);
    }
    @finally
    {
        
    }
}

-(void)deleteImage:(NSUInteger)imageId fromProduct:(NSUInteger)productId success:(JSONRespEmpty)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSString* url = [NSString stringWithFormat:@"seller/product/%zd/photos/%zd", productId, imageId];
    [self.sessionManager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"deleteImage error"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)setProcessStatus:(NSString*)status forProduct:(NSUInteger)productId success:(JSONRespProduct)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSDictionary* params = @{@"id": @(productId), @"process_status": status};
    [self.sessionManager POST:@"seller/product" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            NSDictionary* productDict = [responseObject objectForKey:@"product"];
            Product* product = [Product parseFromJson:productDict];
            success(product);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"setProcessStatus error"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)getSizeValues:(NSString*)attrName success:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/designers/list", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                    long l = (long)[httpResponse statusCode];
                                    if (l == 200)
                                    {
                                          NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                        NSMutableArray* sizeVaules = [NSMutableArray new];
                                        for (NSDictionary* item in [forJSONObject valueForKey:@"data"]) {
                                                    NamedItem* sizeItem = [NamedItem parseFromJson:item];
                                                    [sizeVaules addObject:sizeItem];
                                        }
                                        success(sizeVaules);
                                    }else {
                                            NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    failure([forJSONObject valueForKey:@"message"]);
                                        }
                                                
                            }];
    [task resume];

}

-(void)getUnitAndSizeValues:(NSString*)attrName success:(JSONRespDictionary)success failure:(JSONRespError)failure {
	if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/sizes/list?type=SH", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                long l = (long)[httpResponse statusCode];
                                                if (l == 200)
                                                {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                  
                                                    NSMutableArray* sizeVaules = [NSMutableArray new];
                                                    for (NSDictionary* item in [forJSONObject valueForKey:@"data"]) {
                                                        NamedItem* sizeItem = [NamedItem parseFromJson:item];
                                                        [sizeVaules addObject:sizeItem];
                                                    }
                                                    success(sizeVaules);
                                                }else {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    failure([forJSONObject valueForKey:@"message"]);
                                                }
                                                
                                            }];
    [task resume];

}

-(void)getSellerPayoutForProduct:(NSUInteger)category price:(float)price success:(JSONRespPrice)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    
    
    
    
    
    
    
//    NSString* url = [NSString stringWithFormat:@"/seller/payout/category/%lu/price/%f",
//                     (unsigned long)category, price];
//    NSLog(@"%@", url);
//    [self.sessionManager GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDecimalNumber* responseObject) {
//        success([responseObject floatValue]);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        [self logError:error withCaption:@"getSellerPayoutForProduct error"];
//        failure(DefGeneralErrMsg);
//    }];
}

-(void)getPriceSuggestionForProduct:(Product*)product andOriginalPrice:(float)price success:(JSONRespPrice)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSDictionary* params = @{@"original_price": [NSString stringWithFormat:@"%f", price], @"category_id": [NSString stringWithFormat:@"%d",product.category.idNum], @"designer_id":[NSString stringWithFormat:@"%d", product.designer.identifier], @"condition_id":[NSString stringWithFormat:@"%d", product.condition.identifier]};
    
    NSLog(@"%@",params);
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/price/suggest", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:jsonBodyData];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                long l = (long)[httpResponse statusCode];
                                                if (l == 200)
                                                {
                                                    
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                   
                                                      success(forJSONObject);
                                                }else {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    failure(DefGeneralErrMsg);
                                                   
                                                }
                                                
                                            }];
    [task resume];

}

-(void)getRegionsByCountry:(NSString*)country success:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSString* url = [NSString stringWithFormat:@"checkout/regionsByCountry/%@", country];
    [self.sessionManager GET:url parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        if([response isKindOfClass:[NSNumber class]]) {
            success(nil);
            return;
        }
        
        NSMutableArray* regions = [NSMutableArray new];
        for (NSDictionary* regionDict in response) {
            [regions addObject:[NamedItem parseFromJson:regionDict]];
        }
        success(regions);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"regionsByCountry"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)setShippingAddress:(Address*)address success:(JSONRespEmpty)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    NSArray *testArray2 = [address.contactNumber componentsSeparatedByString:@"-"];
    
    NSMutableDictionary* Phone;
    if (testArray2.count == 2)
    {
       Phone = [@{@"code": address.dialcode,@"value":testArray2[1]}mutableCopy];
    }
    else
    {
       Phone = [@{@"code": address.dialcode,@"value":testArray2[0]}mutableCopy];
    }
    NSMutableDictionary* params = [@{@"city": address.city,
                             @"company": address.company,
                             @"customer_id": address.cusomer_id,
                             @"first_name": address.firstName,
                             @"last_name": address.lastName,
                             @"zipcode": address.zipCode,
                             @"address_1": address.address,
                             @"address_2":@"",
                            @"state":address.state,
                            @"phone":Phone,
                            @"country":address.countryId} mutableCopy];

    NSLog(@"%@",params);
    NSString *token = [@"Bearer " stringByAppendingString:[[NSUserDefaults standardUserDefaults] valueForKey:@"Token"]];
    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/addresses", DefApiHost];
    NSData *jsonBodyData = [NSJSONSerialization dataWithJSONObject:params options:kNilOptions error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"POST";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    [request setHTTPBody:nil];
    [request setHTTPBody:jsonBodyData];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                long l = (long)[httpResponse statusCode];
                if (l == 200)
                {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    NSDictionary* shippingDict = [forJSONObject objectForKey:@"data"];
                    if (shippingDict != nil || shippingDict.count != 0)
                    {
                        
                        [DataCache sharedInstance].shippingAddress = [Address parseFromJson:shippingDict];
                    }
                    
                        success();
                }else {
                        NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                        failure([forJSONObject valueForKey:@"message"]);
                }
                                                
                }];
    [task resume];

}

-(void)getMinimumAppVersionWithSuccess:(JSONRespAppViersion)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;

    NSString* urlString1 = [NSString stringWithFormat:@"%@api/v1/config/public", DefApiHost];
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    request.HTTPMethod = @"GET";
    [request setURL:[NSURL URLWithString:urlString1]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:nil];
    [request setURL:[NSURL URLWithString:urlString1]];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config  delegate:nil  delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                
                                                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                long l = (long)[httpResponse statusCode];
                                                if (l == 200)
                                                {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                  
                                                    NSString* versionString = [[[forJSONObject objectForKey:@"data"] valueForKey:@"mobile_app"] valueForKey:@"ios"];
                                                    success([versionString floatValue]);
                                                }else {
                                                    NSDictionary *forJSONObject = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                    failure([forJSONObject valueForKey:@"message"]);
                                                }
                                                
                                            }];
    [task resume];
    
    
    
    
    
    [self.sessionManager GET:@"" parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        NSString* versionString = [response objectForKey:@"version"];
        success([versionString floatValue]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"getMinimumAppVersion"];
        failure(DefGeneralErrMsg);
    }];
}

@end
