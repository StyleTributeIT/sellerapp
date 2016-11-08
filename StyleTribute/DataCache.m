//
//  Cache.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 14/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "DataCache.h"
#import "Product.h"

@implementation DataCache
static Product* selectedItem;
    
+(DataCache*)sharedInstance
{
    static dispatch_once_t once;
    static DataCache *sharedInstance;
    dispatch_once(&once, ^ {
        sharedInstance = [[DataCache alloc] init];
        sharedInstance.openProductOnstart = 0;
    });
    
//    sharedInstance.conditions = @[@"Gently loved", @"Good", @"Excellent", @"New with tag"];
    
    return sharedInstance;
}

+(Product*)getSelectedItem
{
    return selectedItem;
}
    
+(void)setSelectedItem:(Product*)item
{
    selectedItem = item;
}
    
-(NSString*)getPathInDocuments:(NSString*)relPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return [NSString stringWithFormat:@"%@/%@", basePath, relPath];
}

-(NSMutableArray*)loadItemsFromFile:(NSString*)name {
    NSMutableArray* items = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathInDocuments:name]];
    
    if(items == nil)
        items = [NSMutableArray new];
    
    return items;
}

-(NSMutableArray*)loadProducts {
    return [self loadItemsFromFile:@"products"];
}

-(void)saveProducts:(NSArray*)items {
    [NSKeyedArchiver archiveRootObject:items toFile:[self getPathInDocuments:@"products"]];
}

@end
