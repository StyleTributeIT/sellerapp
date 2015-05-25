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
        NSLog(@"get products internet connection problem");
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
                                    success:(JSONRespLogin)success
                                    failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager POST:@"account/register" parameters:@{@"email":email, @"password":password, @"firstName": firstName, @"lastName": lastName} success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            NSString* token = [responseObject objectForKey:@"token"];
            [self.sessionManager.requestSerializer setValue:token forHTTPHeaderField:@"X-Auth-Token"];
            
            UserProfile* profile = [UserProfile parseFromJson:[responseObject objectForKey:@"model"]];
            success(profile);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"login error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

-(AFHTTPRequestOperation*)loginWithEmail:(NSString*)email andPassword:(NSString*)password success:(JSONRespLogin)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager POST:@"app/authorize" parameters:@{@"email":email, @"password":password} success:^(NSURLSessionDataTask *task, id responseObject) {
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

-(AFHTTPRequestOperation*)logoutWithSuccess:(JSONRespLogout)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return nil;
    
    [self.sessionManager GET:@"app/invalidate" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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

-(AFHTTPRequestOperation*)getProductsWithSuccess:(JSONRespProducts)success failure:(JSONRespError)failure {
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
            success(nil);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getAccount error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    return nil;
}

@end
