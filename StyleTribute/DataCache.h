//
//  Cache.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 14/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"

@interface DataCache : NSObject

+(DataCache*)sharedInstance;

@property NSMutableArray* products;
@property UserProfile* userProfile;
@property NSArray* countries;
@property NSArray* categories;
@property NSString* deviceToken;
@property NSArray* brands;
@property NSArray* conditions;

-(NSMutableArray*)loadProducts;
-(void)saveProducts:(NSArray*)items;

@end
