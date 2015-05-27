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

@property NSMutableArray* sellingItems;
@property NSMutableArray* soldItems;
@property NSMutableArray* archivedItems;
@property UserProfile* userProfile;
@property NSArray* countries;
@property NSArray* categories;

-(NSMutableArray*)loadSellingItems;
-(void)saveSellingItems:(NSArray*)items;

-(NSMutableArray*)loadSoldItems;
-(void)saveSoldItems:(NSArray*)items;

-(NSMutableArray*)loadArchivedItems;
-(void)saveArchivedItems:(NSArray*)items;

@end
