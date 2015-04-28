//
//  ApiRequester.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "ApiRequester.h"

static NSString *const boundary = @"0Xvdfegrdf876fRD";

@implementation ApiRequester

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

@end
