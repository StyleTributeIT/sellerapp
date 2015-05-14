//
//  Cache.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 14/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "DataCache.h"

@implementation DataCache

+(DataCache*)sharedInstance
{
    static dispatch_once_t once;
    static DataCache *sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[DataCache alloc] init]; });
    return sharedInstance;
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

-(NSMutableArray*)loadSellingItems {
    return [self loadItemsFromFile:@"sellingItems"];
}

-(void)saveSellingItems:(NSArray*)items {
    [NSKeyedArchiver archiveRootObject:items toFile:[self getPathInDocuments:@"sellingItems"]];
}

-(NSMutableArray*)loadSoldItems {
    return [self loadItemsFromFile:@"soldItems"];
}

-(void)saveSoldItems:(NSArray*)items {
    [NSKeyedArchiver archiveRootObject:items toFile:[self getPathInDocuments:@"soldItems"]];
}

-(NSMutableArray*)loadArchivedItems {
    return [self loadItemsFromFile:@"archivedItems"];
}

-(void)saveArchivedItems:(NSArray*)items {
    [NSKeyedArchiver archiveRootObject:items toFile:[self getPathInDocuments:@"archivedItems"]];
}

@end
