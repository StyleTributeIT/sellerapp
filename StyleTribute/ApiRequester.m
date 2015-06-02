//
//  ApiRequester.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ApiRequester.h"
#import "Product.h"
#import "GlobalHelper.h"
#import <Reachability.h>
#import "UserProfile.h"
#import "Country.h"
#import "Category.h"
#import "DataCache.h"

static NSString *const boundary = @"0Xvdfegrdf876fRD";

@interface ApiRequester ()

@property AFHTTPSessionManager* sessionManager;

@end

@implementation ApiRequester

#pragma mark - Helper methods

+(ApiRequester*)sharedInstance
{
    static dispatch_once_t once;
    static ApiRequester *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[ApiRequester alloc] init];
        sharedInstance.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:DefApiHost]];
        sharedInstance.sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        
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

#pragma mark - API methods

-(AFHTTPRequestOperation*)registerWithEmail:(NSString*)email
                                   password:(NSString*)password
                                  firstName:(NSString*)firstName
                                   lastName:(NSString*)lastName
                                   userName:(NSString*)userName
                                    country:(NSString*)country
                                      phone:(NSString*)phone
                                    success:(JSONRespAccount)success
                                    failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    NSDictionary* params = @{@"email":email, @"password":password, @"firstname": firstName, @"lastname": lastName, @"username": userName, @"country": country, @"phone_number": phone};
    [self.sessionManager POST:@"seller/register" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            NSString* token = [responseObject objectForKey:@"token"];
            [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"X-Auth-Token"];
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            [defs setObject:token forKey:@"apiToken"];
            [defs synchronize];
            
            UserProfile* profile = [UserProfile parseFromJson:[responseObject objectForKey:@"model"]];
            success(profile);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"registration error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)loginWithEmail:(NSString*)email andPassword:(NSString*)password success:(JSONRespAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager POST:@"authorize" parameters:@{@"email":email, @"password":password} success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            NSString* token = [responseObject objectForKey:@"token"];
            [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"X-Auth-Token"];
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            [defs setObject:token forKey:@"apiToken"];
            [defs synchronize];
            
            UserProfile* profile = [UserProfile parseFromJson:[responseObject objectForKey:@"model"]];
            success(profile);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"login error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)loginWithFBToken:(NSString*)fbToken success:(JSONRespFBLogin)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
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
        NSLog(@"FB login error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)logoutWithSuccess:(JSONRespEmpty)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager GET:@"invalidate" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            [self.sessionManager.requestSerializer setValue:nil forHTTPHeaderField:@"X-Auth-Token"];
            NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
            [defs removeObjectForKey:@"apiToken"];
            [defs synchronize];
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"logout error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)getProductsWithSuccess:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager GET:@"products/filter/10/0" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getProducts error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)getAccountWithSuccess:(JSONRespAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager GET:@"account" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success([UserProfile parseFromJson:[responseObject objectForKey:@"model"]]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getAccount error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)getCountries:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager GET:@"checkout/countryList" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseObject) {
        NSMutableArray* countries = [NSMutableArray new];
        for (NSDictionary* countryDict in responseObject) {
            [countries addObject:[Country parseFromJson:countryDict]];
        }
        success(countries);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getCountries error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)getCategories:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager GET:@"categories" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseObject) {
        NSMutableArray* categories = [NSMutableArray new];
        for (NSDictionary* categoryDict in responseObject) {
            [categories addObject:[STCategory parseFromJson:categoryDict]];
        }
        success(categories);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getCategories error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)getProducts:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager GET:@"seller/products" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseObject) {
        NSMutableArray* products = [NSMutableArray new];
//        for (NSDictionary* productDict in responseObject) {
//        }
        success(products);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getProducts error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)setDeviceToken:(NSString*)token success:(JSONRespEmpty)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager POST:@"deviceToken" parameters:@{@"deviceToken":token} success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"setDeviceToken error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)getBankAccount:(JSONRespBankAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager GET:@"seller/bankAccount" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success([BankAccount parseFromJson:responseObject]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getBankAccount error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)setBankAccountWithBankName:(NSString*)bankName
                                            bankCode:(NSString*)bankCode
                                         beneficiary:(NSString*)beneficiary
                                       accountNumber:(NSString*)accountNumber
                                          branchCode:(NSString*)branchCode
                                             success:(JSONRespEmpty)success
                                             failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    NSDictionary* params = @{@"bankname":bankName, @"bankcode":bankCode, @"bankbeneficiary":beneficiary, @"bankaccountnumber":accountNumber, @"bankbranchcode":branchCode};
    [self.sessionManager POST:@"seller/bankAccount" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"setDeviceToken error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

@end
