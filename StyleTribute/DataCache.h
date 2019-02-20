//
//  Cache.h
//  StyleTribute
//
//  Created by Selim Mustafaev on 14/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserProfile.h"
#import "Product.h"
@interface DataCache : NSObject

+(DataCache*)sharedInstance;
+(Product*)getSelectedItem;
+(void)setSelectedItem:(Product*)item;
    
@property NSMutableArray* products;
@property NSArray* kidzSizes;
@property UserProfile* userProfile;
@property BankAccount* bankAccount;
@property Address* shippingAddress;
@property NSArray* countries;
@property NSArray* categories;
@property NSString* deviceToken;
@property NSArray* conditions;
@property NSArray* designers;
@property NSUInteger openProductOnstart;
@property NSDictionary* units;

//remove: @property NSArray* sizes;
@property NSArray* shoeSizes;
@property BOOL isEditingItem;

-(NSMutableArray*)loadProducts;

-(void)saveProducts:(NSArray*)items;
    
@end
