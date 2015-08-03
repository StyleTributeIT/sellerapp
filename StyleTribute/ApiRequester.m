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
#import "NamedItems.h"

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
        sharedInstance.sessionManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
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
    
    NSDictionary* params = @{@"email":email, @"password":password, @"firstName": firstName, @"lastName": lastName, @"userName": userName, @"country": country, @"phone": phone};
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
}

-(void)loginWithEmail:(NSString*)email andPassword:(NSString*)password success:(JSONRespAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
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
        NSLog(@"FB login error: %@", [error description]);
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
            [defs synchronize];
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"logout error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)getAccountWithSuccess:(JSONRespAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"account" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success([UserProfile parseFromJson:[responseObject objectForKey:@"model"]]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getAccount error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)getCountries:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
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
}

-(void)getCategories:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"seller/categories" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseObject) {
        NSMutableArray* categories = [NSMutableArray new];
        for (NSDictionary* categoryDict in responseObject) {
            [categories addObject:[STCategory parseFromJson:categoryDict]];
        }
        success(categories);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getCategories error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)getProducts:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"seller/products" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseArray) {
        NSMutableArray* products = [NSMutableArray new];
        for (NSDictionary* productDict in responseArray) {
            Product* product = [Product parseFromJson:productDict];
            [products addObject:product];
        }
        success(products);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getProducts error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)setDeviceToken:(NSString*)token success:(JSONRespEmpty)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager POST:@"deviceToken" parameters:@{@"deviceToken":token} success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"setDeviceToken error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)getBankAccount:(JSONRespBankAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"seller/bankAccount" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success([BankAccount parseFromJson:responseObject]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getBankAccount error: %@", [error description]);
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
    
    NSDictionary* params = @{@"bankname":bankName, @"bankcode":bankCode, @"bankbeneficiary":beneficiary, @"bankaccountnumber":accountNumber, @"bankbranchcode":branchCode};
    [self.sessionManager POST:@"seller/bankAccount" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"setDeviceToken error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)getDesigners:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"seller/designers" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseObject) {
        NSMutableArray* designers = [NSMutableArray new];
        for (NSDictionary* designerDict in responseObject) {
            [designers addObject:[NamedItem parseFromJson:designerDict]];
        }
        success(designers);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getDesigners error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)getConditions:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"seller/conditions" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseObject) {
        NSMutableArray* conditions = [NSMutableArray new];
        for (NSDictionary* conditionDict in responseObject) {
            [conditions addObject:[NamedItem parseFromJson:conditionDict]];
        }
        success(conditions);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"getConditions error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)setAccountWithUserName:(NSString*)userName
                    firstName:(NSString*)firstName
                     lastName:(NSString*)lastName
                      country:(NSString*)country
                        phone:(NSString*)phone
                      success:(JSONRespEmpty)success
                      failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSDictionary* params = @{@"userName":userName, @"firstName": firstName, @"lastName": lastName, @"country": country, @"phone": phone};
    [self.sessionManager POST:@"seller/account" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"setAccount error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)setProductWithId:(NSUInteger)identifier
                   name:(NSString*)name
            description:(NSString*)description
              shortDesc:(NSString*)shortDesc
                  price:(float)price
               category:(NSUInteger)categoryId
              condition:(NSUInteger)conditionId
               designer:(NSUInteger)designerId
                success:(JSONRespProduct)success
                failure:(JSONRespError)failure  {
    
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSMutableDictionary* params = [@{@"name": name, @"description": description, @"short_description": shortDesc, @"category": @(categoryId), @"condition": @(conditionId), @"designer": @(designerId)} mutableCopy];
    if(identifier > 0) {
        [params setObject:@(identifier) forKey:@"id"];
    }
    
    [self.sessionManager POST:@"seller/product" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            NSDictionary* productDict = [responseObject objectForKey:@"product"];
            Product* product = [Product parseFromJson:productDict];
            success(product);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"setProduct error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

-(void)uploadImage:(UIImage*)image ofType:(NSString*)type toProduct:(NSUInteger)productId success:(JSONRespEmpty)success failure:(JSONRespError)failure progress:(JSONRespProgress)progress {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    NSString* url = [NSString stringWithFormat:@"%@seller/product/%zd/photos", DefApiHost, productId];
    NSDictionary* params = @{@"label": type};
    
    NSProgress *p;
    NSMutableURLRequest *request = [self.sessionManager.requestSerializer  multipartFormRequestWithMethod:@"POST" URLString:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    
    [self.sessionManager setTaskDidSendBodyDataBlock:^(NSURLSession *session, NSURLSessionTask *task, int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        progress(1.0*totalBytesSent/totalBytesExpectedToSend);
    }];
    
    NSURLSessionUploadTask* task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:&p completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if(error) {
            NSLog(@"uploadImage error: %@", [error description]);
            failure(DefGeneralErrMsg);
        } else {
            success();
        }
    }];
    
    [task resume];
}

-(void)deleteImage:(NSUInteger)imageId fromProduct:(NSUInteger)productId success:(JSONRespEmpty)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSString* url = [NSString stringWithFormat:@"seller/product/%zd/photos/%zd", productId, imageId];
    [self.sessionManager DELETE:url parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"deleteImage success: %@", [responseObject description]);
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"deleteImage error: %@", [error description]);
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
        NSLog(@"setProcessStatus error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
}

@end
