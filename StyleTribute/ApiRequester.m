//
//  ApiRequester.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ApiRequester.h"
#import "Product.h"

static NSString *const boundary = @"0Xvdfegrdf876fRD";

@implementation ApiRequester

#pragma mark - Helper methods

+(ApiRequester*)sharedInstance
{
    static dispatch_once_t once;
    static ApiRequester *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[ApiRequester alloc] init]; });
    return sharedInstance;
}

-(NSMutableURLRequest*)postReqToApiPath:(NSString*)apiPath postBody:(NSString*)body
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[DefApiHost stringByAppendingString:apiPath]]];
    //	NSLog(@"API token: %@", cook);
    
    [req setHTTPShouldHandleCookies:NO];
//    [req addValue:cook forHTTPHeaderField:DefApiToken];
    [req setHTTPMethod:@"POST"];
    if (body && body.length > 0)
        [req setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
    return req;
}

-(NSMutableURLRequest*)getReqToApiPath:(NSString*)apiPath
{
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[DefApiHost stringByAppendingString:apiPath]]];
    [req setHTTPShouldHandleCookies:NO];
//    [req addValue:cook forHTTPHeaderField:DefApiToken];
    [req setHTTPMethod:@"GET"];
    return req;
}

#pragma mark - API methods

-(AFHTTPRequestOperation*)getProductsWithSuccess:(JSONRespProducts)success failure:(JSONRespError)failure
{
    NSMutableURLRequest *req = [self getReqToApiPath:@"products.json"];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:req];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if([[responseObject objectForKey:@"success"] boolValue] == YES) {
            NSMutableArray* products = [NSMutableArray new];
            NSArray* productsArray = [responseObject objectForKey:@"data"];
            if(productsArray) {
                for (NSDictionary* productDict in productsArray) {
                    Product* product = [Product parseFromJson:productDict];
                    [products addObject:product];
                }
            }
            success(products);
        } else {
            NSString* errMsg = [responseObject objectForKey:@"message"];
            if(errMsg == nil) {
                errMsg = DefGeneralErrMsg;
            }
            
            NSLog(@"get products error: %@", errMsg);
            failure(errMsg);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"get products request error: %@", [error description]);
        failure(DefGeneralErrMsg);
    }];
    
    [operation start];
    return operation;
}

@end
