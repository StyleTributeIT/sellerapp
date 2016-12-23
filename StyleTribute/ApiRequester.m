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
    
    NSDictionary* params = @{@"email":email, @"password":password, @"firstName": firstName, @"lastName": lastName, /* @"userName": userName, @"country": country, */ @"phone": phone};
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
        [self logError:error withCaption:@"registration error"];
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
        [self logError:error withCaption:@"login error"];
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

-(void)getAccountWithSuccess:(JSONRespAccount)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"account" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success([UserProfile parseFromJson:[responseObject objectForKey:@"model"]]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"getAccount error"];
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
        [self logError:error withCaption:@"getCountries error"];
        failure(DefGeneralErrMsg);
    }];
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
    
    [self.sessionManager GET:@"seller/categories" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseObject) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
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

-(void)getProducts:(JSONRespArray)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"seller/products" parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseArray) {
        NSMutableArray* products = [NSMutableArray new];
        for (NSDictionary* productDict in responseArray) {
            Product* product = [Product parseFromJson:productDict];
            [products addObject:product];
        }
       /* NSUInteger productId = 9434;
        NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
        NSMutableArray *prods = [NSMutableArray arrayWithArray:[defs objectForKey:@"notifications"]];
        if (!prods)
            prods = [[NSMutableArray alloc] init];
        [prods addObject:@{@"alert":@"Test alert",@"pid":@"9434"}];
        [defs setObject:prods forKey:@"notifications"];
        [defs synchronize];
        // get product name from id
        if([DataCache sharedInstance].products != nil) {
            Product* product = [[[DataCache sharedInstance].products linq_where:^BOOL(Product* p) {
                return (p.identifier == productId);
            }] firstObject];
            
            if(product != nil) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //                [GlobalHelper showMessage:alert withTitle:product.name];
                    Photo* photo = [product.photos firstObject];
                    [GlobalHelper showToastNotificationWithTitle:product.name subtitle:@"Test image" imageUrl:(photo ? photo.imageUrl : nil)];
                });
            }
        }*/
        success(products);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"getProducts error"];
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
    
    NSDictionary* params = @{@"bankname":bankName, @"bankcode":bankCode, @"bankbeneficiary":beneficiary, @"bankaccountnumber":accountNumber, @"bankbranchcode":branchCode};
    [self.sessionManager POST:@"seller/bankAccount" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"setDeviceToken error"];
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
        [self logError:error withCaption:@"getDesigners error"];
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
        [self logError:error withCaption:@"getConditions error"];
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

-(void)setProduct:(Product*)product success:(JSONRespProduct)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSMutableDictionary* params = [@{@"name": product.name,
                                     @"description": product.descriptionText,
                                     @"short_description": @"",
                                     @"category": @(product.category.idNum),
                                     @"condition": @(product.condition.identifier),
                                     @"designer": @(product.designer.identifier),
                                     @"original_price": @(product.originalPrice),
                                     @"price": @(product.price)} mutableCopy];
    
    NSString* firstSize = [product.category.sizeFields firstObject];
    if([firstSize isEqualToString:@"size"]) {
        [params setObject:@[product.unit, product.size] forKey:@"size"];
    } else if([firstSize isEqualToString:@"shoesize"]) {
        [params setObject:@(product.shoeSize.identifier) forKey:@"shoesize"];
        if(product.heelHeight)
            [params setObject:product.heelHeight forKey:@"heel_height"];
    } else if([firstSize isEqualToString:@"dimensions"] && product.dimensions) {
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
    
    if(product.identifier > 0) {
        [params setObject:@(product.identifier) forKey:@"id"];
    }
    if(product.processStatus.length > 0) {
        [params setObject:product.processStatus forKey:@"process_status"];
    }
    
    [self.sessionManager POST:@"seller/product" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if([self checkSuccessForResponse:responseObject errCalback:failure]) {
            NSDictionary* productDict = [responseObject objectForKey:@"product"];
            Product* product = [Product parseFromJson:productDict];
            success(product);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"setProduct error"];
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
            [self logError:error withCaption:@"uploadImage error"];
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
    
	[self.sessionManager GET:[@"seller/getAttributePossibleValues/" stringByAppendingString:attrName]  parameters:nil success:^(NSURLSessionDataTask *task, NSArray* responseArray) {
        NSMutableArray* sizeVaules = [NSMutableArray new];
        for (NSDictionary* item in responseArray) {
            NamedItem* sizeItem = [NamedItem parseFromJson:item];
            [sizeVaules addObject:sizeItem];
        }
        success(sizeVaules);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"getSizeValues error"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)getUnitAndSizeValues:(NSString*)attrName success:(JSONRespDictionary)success failure:(JSONRespError)failure {
	if(![self checkInternetConnectionWithErrCallback:failure]) return;
	
	[self.sessionManager GET:[@"seller/getAttributePossibleValues/" stringByAppendingString:attrName]  parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary* response) {
		
		NSMutableDictionary* units = [NSMutableDictionary new];
		[response enumerateKeysAndObjectsUsingBlock:^(NSString* unit, NSArray* responseSize, BOOL *stop) {
			
			NSMutableArray* sizeVaules = [NSMutableArray new];
			for (NSArray* item in responseSize)
			{
				NamedItem* sizeItem = [NamedItem new];
    
				sizeItem.identifier = (NSUInteger)[item[1] integerValue];
				
				NSObject* value = item[0];
				if([value respondsToSelector:@selector(stringValue)]) {
					value = [value performSelector:@selector(stringValue)];
				}
				sizeItem.name = [BaseModel validatedString:(NSString*)value];
			
				[sizeVaules addObject:sizeItem];
			}
			
			units[unit] = sizeVaules;
			
		}];
		success(units);
		
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		[self logError:error withCaption:@"getSizeValues error"];
		failure(DefGeneralErrMsg);
	}];
}

-(void)getPriceSuggestionForProduct:(Product*)product andOriginalPrice:(float)price success:(JSONRespPrice)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    NSString* url = [NSString stringWithFormat:@"seller/priceSuggestion/designer/%zd/condition/%zd/category/%zd/original/%f",
                     product.designer.identifier, product.condition.identifier, product.category.idNum, price];
    [self.sessionManager GET:url parameters:nil success:^(NSURLSessionDataTask *task, NSDecimalNumber* responseObject) {
        success([responseObject floatValue]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"getPriceSuggestionForProduct error"];
        failure(DefGeneralErrMsg);
    }];
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
    
    NSMutableDictionary* params = [@{@"city": address.city,
                             @"company": address.company,
                             @"country_id": address.countryId,
                             @"firstname": address.firstName,
                             @"lastname": address.lastName,
                             @"postcode": address.zipCode,
                             @"street": address.address,
                             @"telephone": address.contactNumber } mutableCopy];
    
    if(address.state) {
        [params setObject:address.state.name forKey:@"region"];
        [params setObject:[@(address.state.identifier) stringValue] forKey:@"region_id"];
    }
    
    [self.sessionManager POST:@"account/setShippingAddress" parameters:params success:^(NSURLSessionDataTask *task, id response) {
        if([self checkSuccessForResponse:response errCalback:failure]) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"setShippingAddress"];
        failure(DefGeneralErrMsg);
    }];
}

-(void)getMinimumAppVersionWithSuccess:(JSONRespAppViersion)success failure:(JSONRespError)failure {
    if(![self checkInternetConnectionWithErrCallback:failure]) return;
    
    [self.sessionManager GET:@"seller/minimumAppVersion" parameters:nil success:^(NSURLSessionDataTask *task, id response) {
        NSString* versionString = [response objectForKey:@"version"];
        success([versionString floatValue]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self logError:error withCaption:@"getMinimumAppVersion"];
        failure(DefGeneralErrMsg);
    }];
}

@end
