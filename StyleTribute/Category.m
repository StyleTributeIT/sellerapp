//
//  Category.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 27/05/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Category.h"
#import "ImageType.h"

@interface STCategory () <NSCoding>

@end

@implementation STCategory

+(instancetype)parseFromJson:(NSDictionary*)dict; {
    STCategory* category = [STCategory new];
  //  NSLog(@"%@",dict);

    category.idNum = (NSUInteger)[self parseInt:@"id" fromDict:dict];
    category.name = [self parseString:@"name" fromDict:dict];
    category.thumbnail = [self parseString:@"thumbnail_image" fromDict:dict];
    
    NSMutableArray* imgTypes = [NSMutableArray new];
    NSDictionary* imgTypeArray = [[dict objectForKey:@"media_supports"] valueForKey:@"data"];
    if (imgTypeArray != nil)
    {
        if (imgTypeArray.count > 0)
        {
            NSLog(@"imgTypeArray: %@", imgTypeArray);
        }
    }
    
    if(imgTypeArray != nil)
    {
        for(NSDictionary* imgTypeDict in imgTypeArray)
        {
            ImageType* imgType = [ImageType parseFromJson:imgTypeDict];
            [imgTypes addObject:imgType];
        }
    }
    category.imageTypes = imgTypes;
//    category.sizeFields = [dict objectForKey:@"size_fields"];
//    if (category.sizeFields != nil)
//    {
//        NSLog(@"size Fields isn't null");
//    }
    NSMutableArray* categories = [NSMutableArray new];
    for (NSDictionary* categoryDict in [[dict objectForKey:@"categories"] valueForKey:@"data"]) {
        [categories addObject:[STCategory parseFromJson:categoryDict]];
    }
    category.children = [NSArray arrayWithArray:categories];
    return category;
}

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.idNum = [[decoder decodeObjectForKey:@"id"] unsignedIntegerValue];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.thumbnail = [decoder decodeObjectForKey:@"thumbnail"];
    self.imageTypes = [decoder decodeObjectForKey:@"imageTypes"];
    self.sizeFields = [decoder decodeObjectForKey:@"sizeFields"];
    self.children = [decoder decodeObjectForKey:@"children"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.idNum) forKey:@"id"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.thumbnail forKey:@"thumbnail"];
    [encoder encodeObject:self.imageTypes forKey:@"imageTypes"];
    [encoder encodeObject:self.sizeFields forKey:@"sizeFields"];
    [encoder encodeObject:self.children forKey:@"children"];
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]){
        STCategory *stCategory = (STCategory *) object;
        
        if (!(stCategory.name && _name && [stCategory.name isEqualToString:_name])){
            if (!(!stCategory.name && !_name)) {
                return NO;
            }
        }
        if (!(stCategory.idNum && _idNum && stCategory.idNum == _idNum)){
            if (!(!stCategory.idNum && !_idNum)) {
                return NO;
            }
        }
        if (!(stCategory.thumbnail && _thumbnail && [stCategory.thumbnail isEqualToString:_thumbnail])){
            if (!(!stCategory.thumbnail && !_thumbnail)) {
                return NO;
            }
        }
        if (!(stCategory.imageTypes && _imageTypes && [stCategory.imageTypes isEqualToArray:_imageTypes])){
            if (!(!stCategory.imageTypes && !_imageTypes)) {
                return NO;
            }
        }
        if (!(stCategory.sizeFields && _sizeFields && [stCategory.sizeFields isEqualToArray:_sizeFields])){
            if (!(!stCategory.sizeFields && !_sizeFields)) {
                return NO;
            }
        }
    }else{
        return NO;
    }
    return YES;
}

- (id)copyWithZone:(NSZone *)zone{
    STCategory *newCategory = [[STCategory allocWithZone:zone] init];
    newCategory.idNum = _idNum;
    newCategory.name = [_name copy];
    newCategory.thumbnail = [_thumbnail copy];
    newCategory.imageTypes = [_imageTypes copy];
    newCategory.sizeFields = [_sizeFields copy];
    return newCategory;
}

@end
