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
    
    // Hardcoded for now
    sharedInstance.brands = @[@"3.1 PHILLIP LIM", @"7 FOR ALL MANKIND", @"A.J. BARI", @"A.L.C", @"ABS", @"ABS ALLEN SCHWARTZ", @"ACNE", @"ADAM LIPPES", @"ADOLFO DOMINGUES", @"ADRIANNA PAPELL", @"ADRIENNE VITTADINI", @"AGENT PROVOCATEUR", @"AGNES B", @"AIDA MADDOX", @"AIDAN MATTOX", @"AIGNER", @"AKIRA", @"ALAIA", @"ALANNAH HILL", @"ALBANO", @"ALBERTA FERRETTI", @"ALESSANDRA RICH", @"ALEXANDER MCQUEEN"];
    sharedInstance.conditions = @[@"Gently loved", @"Good", @"Excellent", @"New with tag"];
    
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
