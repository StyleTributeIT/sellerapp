//
//  Product.m
//  StyleTribute
//
//  Created by Selim Mustafaev on 28/04/15.
//  Copyright (c) 2015 Selim Mustafaev. All rights reserved.
//

#import "Product.h"
#import "Photo.h"

@implementation Product
STCategory *pCategory = nil;

-(instancetype)init {
    self = [super init];
    if(self) {
        self.type = ProductTypeSelling;
        self.processStatus = @"";
        self.identifier = 0;
        self.originalPrice = 0;
        self.suggestedPrice = 0;
        self.price = 0;
    }
    return self;
}

+ (STCategory*)visitNode:(STCategory *)node forId:(NSUInteger)categoryId {
    STCategory *category = nil;
    NSArray *childrenToVisit = [node children];
    unsigned i, count = (int)childrenToVisit.count;
    
    // visit the current node:
    if ([self printData:node forId:categoryId] != nil)
        category = [self printData:node forId:categoryId];
    if (category != nil)
        return category;
    
    // if there are no children, then recursion ends:
    for (i = 0; i < count; i++)    // make recursive call:
        category = [self visitNode:[childrenToVisit objectAtIndex:i] forId:categoryId];
    return category;
}

+ (STCategory*)printData:(STCategory *)node forId:(NSUInteger)categoryId {
    // this is just an example - in reality you might do something useful!
    if (node.idNum == categoryId)
        pCategory = node;
    return nil;
        //NSLog(@"%lu", (unsigned long)node.idNum);
}

+(STCategory*)searchCategory:(NSArray*)childrens forId:(NSUInteger)categoryId nextIndex:(int)idx
{
    
    for (STCategory *cat in childrens) {
        [self visitNode:cat forId:categoryId];
    }
    
   /* category = [[childrens linq_where:^BOOL(STCategory* category) {
        return (category.idNum == categoryId);
    }] firstObject];
    if (category == nil)
    {
        idx++;
        if ([[[childrens objectAtIndex:idx] children] count] != 0)
        {
            [self searchCategory:[[childrens objectAtIndex:idx] children] forId:categoryId nextIndex:idx];
        }
    }*/
    /*STCategory *category = nil;
    for(int i = 0; i < childrens.count; i++){
        STCategory *st = [childrens objectAtIndex:i];
        if (st.idNum == categoryId){
            category = st;
            break;
        }
    }
    if (category == nil)
    {
        
    }
    
    /*category = [[childrens linq_where:^BOOL(STCategory* category) {
        return (category.idNum == categoryId);
    }] firstObject];
    if (category == nil)
    {
        idx++;
        if ([[[childrens objectAtIndex:idx] children] count] != 0)
        {
            [self searchCategory:[[childrens objectAtIndex:idx] children] forId:categoryId nextIndex:idx];
        }
    }*/
    if (pCategory == nil)
    {
        NSLog(@"Category is NIL");
    }
    return pCategory;
}

+(instancetype)parseFromJson:(NSDictionary*)dict {
    NSLog(@"%@",dict);
    
    Product* product = [Product new];
    NSDictionary *dicttemp = [[dict valueForKey:@"process_status"] valueForKey:@"data"];
    product.identifier = (NSUInteger)[self parseLong:@"id" fromDict:dict];
    product.name = [self parseString:@"name" fromDict:dict];
    product.processStatus = [self parseString:@"name" fromDict:dicttemp];
    product.originalPrice = [self parseFloat:@"original_price" fromDict:dict];
    product.price = product.savedPrice = [self parseFloat:@"price" fromDict:dict];//[[self parseString:@"price" fromDict:dict] floatValue];
    product.descriptionText = [self parseString:@"description" fromDict:dict];
    product.url = [self parseString:@"partner_url" fromDict:dict];
    product.share_text = [self parseString:@"share_text" fromDict:dict];
    
    product.allowedTransitions = [NSMutableArray new];
    
    NSArray *transition = [NSArray arrayWithObjects:@"ARCHIVED",@"IMAGE_PROCESSING",@"REJECTED",@"INCOMPLETE",@"INCOMPLETE",@"READY_FOR_SALE",@"IN_REVIEW", nil];
  
    
    
    //NSArray* transitionsArray = [dict objectForKey:@"allowed_transitions"];
    if(transition != nil) for(NSString* transition in transition) {
        [product.allowedTransitions addObject:transition];
    }
    
    // Uncomment this to test transitions
    //    [product.allowedTransitions addObject:@"archived"];
    //    [product.allowedTransitions addObject:@"deleted"];
    
    if([DataCache sharedInstance].categories != nil) {
        
        @try {
            NSArray * categories = [DataCache sharedInstance].categories;
            NSArray *arrcatefories = [[dict objectForKey:@"categories"] valueForKey:@"data"];
            NSDictionary *dictcategpries = arrcatefories[0];
            NSLog(@"%@",dictcategpries);
            NSUInteger categoryId = (NSUInteger)[[dictcategpries objectForKey:@"id"] intValue];
            
            product.category = [self searchCategory:categories forId:categoryId nextIndex:-1];
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            
        }
        @finally {
            NSLog(@"Finally condition");
        }
        
        
       
    }
    
    if([DataCache sharedInstance].conditions != nil) {
        @try {
            NSArray * categories = [DataCache sharedInstance].conditions;
            NSUInteger conditionId = (NSUInteger)[[dict objectForKey:@"condition_id"] intValue];
            product.condition = [[categories linq_where:^BOOL(NamedItem* condition) {
                return (condition.identifier == conditionId);
            }] firstObject];
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
            
        }
        @finally {
            NSLog(@"Finally condition");
        }
       
    }
    
    if([DataCache sharedInstance].designers != nil) {
        @try {
              NSUInteger designerId = (NSInteger)[[dict valueForKey:@"designer_id"] intValue];
            product.designer = [[[DataCache sharedInstance].designers linq_where:^BOOL(NamedItem* designer) {
                        return (designer.identifier = designerId);
                }] firstObject];
            
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception.reason);
         
        }
        @finally {
            NSLog(@"Finally condition");
        }
    }
    
    product.photos = [[NSMutableArray alloc] initWithCapacity:product.category.imageTypes.count];
    for(int i = 0; i < product.category.imageTypes.count; ++i) {
        [product.photos addObject:[NSNull null]];
    }
    
    NSArray* images = [[dict objectForKey:@"media"] valueForKey:@"data"];
    if(images != nil) for(NSDictionary* imageDict in images) {
        Photo* photo = [Photo parseFromJson:imageDict];
        ImageType* type = [[product.category.imageTypes linq_where:^BOOL(ImageType* imgType) {
            return [imgType.type isEqualToString:photo.label];
        }] firstObject];
        
        if(type != nil) {
            NSUInteger index = [product.category.imageTypes indexOfObject:type];
            if(index < product.photos.count) {
                [product.photos replaceObjectAtIndex:index withObject:photo];
            }
        } else {
            // additional image
            [product.photos addObject:photo];
        }
    }
  
    NSString* dimensions = [dict objectForKey:@"dimensions"];
    if(dimensions) {
       // NSArray *listItems = [list componentsSeparatedByString:@"x"];
        NSString* width = @"35"; //listItems[0];
        NSString* height = @"12"; //listItems[1];
        NSString* depth = @"35";//listItems[2];
        product.dimensions = @[width, height, depth];
    }
    if ([dict valueForKey:@"size"] != nil)
    {
        NSLog(@"size");
        product.kidzsize = [dict valueForKey:@"size"];
    }
    
   // product.sizeId = [self parseInt:@"size_id" fromDict:dict];
    product.heelHeight = [self parseString:@"heel_height" fromDict:dict];
    
    // sizeId -> unit  & size
    if(product.sizeId && [DataCache sharedInstance].units != nil) {
        [[DataCache sharedInstance].units enumerateKeysAndObjectsUsingBlock:^(NSString* unit, NSArray* sizes, BOOL *stop) {
            for(NamedItem* size in sizes) {
                if(size.identifier == product.sizeId) {
                    product.unit = unit;
                    product.size = size.name;
                    
                    *stop = YES;
                    break;
                }
            }
        }];
    }
    
    product.processComment = [self parseString:@"process_status_comment" fromDict:dict];
    product.processStatusDisplay = [self parseString:@"name" fromDict:[[dict valueForKey:@"process_status"] valueForKey:@"data"]];
    
    NSUInteger shoesizeId = (NSUInteger)[[self parseString:@"shoe_size" fromDict:dict] integerValue];
    if([DataCache sharedInstance].shoeSizes) {
        product.shoeSize = [[[DataCache sharedInstance].shoeSizes linq_where:^BOOL(NamedItem* item) {
            return (item.identifier == shoesizeId);
        }] firstObject];
    }
    return product;
}

#pragma mark - NSCoding

-(instancetype)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(!self) {
        return nil;
    }
    
    self.identifier = [[decoder decodeObjectForKey:@"id"] unsignedIntegerValue];
    self.type = [[decoder decodeObjectForKey:@"type"] unsignedIntegerValue];
    self.name = [decoder decodeObjectForKey:@"name"];
    self.processStatus = [decoder decodeObjectForKey:@"processStatus"];
    self.processStatusDisplay = [decoder decodeObjectForKey:@"processStatusDisplay"];
    self.processComment = [decoder decodeObjectForKey:@"processComment"];
    self.category = [decoder decodeObjectForKey:@"category"];
    self.photos = [decoder decodeObjectForKey:@"photos"];
    self.originalPrice = [[decoder decodeObjectForKey:@"originalPrice"] floatValue];
    self.suggestedPrice = [[decoder decodeObjectForKey:@"suggestedPrice"] floatValue];
    self.price = [[decoder decodeObjectForKey:@"price"] floatValue];
    self.allowedTransitions = [decoder decodeObjectForKey:@"allowedTransitions"];
    self.descriptionText = [decoder decodeObjectForKey:@"descriptionText"];
	self.unit = [decoder decodeObjectForKey:@"unit"];
    self.size = [decoder decodeObjectForKey:@"size"];
    self.shoeSize = [decoder decodeObjectForKey:@"shoesize"];
    self.heelHeight = [decoder decodeObjectForKey:@"heelHeight"];
    self.dimensions = [decoder decodeObjectForKey:@"dimensions"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:@(self.identifier) forKey:@"id"];
    [encoder encodeObject:@(self.type) forKey:@"type"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.processStatus forKey:@"processStatus"];
    [encoder encodeObject:self.processStatusDisplay forKey:@"processStatusDisplay"];
    [encoder encodeObject:self.processComment forKey:@"processComment"];
    [encoder encodeObject:self.category forKey:@"category"];
    [encoder encodeObject:self.photos forKey:@"photos"];
    [encoder encodeObject:@(self.originalPrice) forKey:@"originalPrice"];
    [encoder encodeObject:@(self.suggestedPrice) forKey:@"suggestedPrice"];
    [encoder encodeObject:@(self.price) forKey:@"price"];
    [encoder encodeObject:self.allowedTransitions forKey:@"allowedTransitions"];
    [encoder encodeObject:self.descriptionText forKey:@"descriptionText"];
	[encoder encodeObject:self.unit forKey:@"unit"];
    [encoder encodeObject:self.size forKey:@"size"];
    [encoder encodeObject:self.shoeSize forKey:@"shoesize"];
    [encoder encodeObject:self.heelHeight forKey:@"heelHeight"];
    [encoder encodeObject:self.dimensions forKey:@"dimensions"];
}

#pragma mark - Helpers

-(ProductType)getProductType {
    if([self.processStatus isEqualToString:@"new"] ||
       [self.processStatus isEqualToString:@"IN_REVIEW"] ||
       [self.processStatus isEqualToString:@"IN_REVIEW_ADD"] ||
       [self.processStatus isEqualToString:@"INCOMPLETE"] ||
       [self.processStatus isEqualToString:@"IMAGE_PROCESSING"] ||
       [self.processStatus isEqualToString:@"SELLING"] ||
       [self.processStatus isEqualToString:@"REJECTED"] ||
       [self.processStatus isEqualToString:@"DECLINED"] ||
       [self.processStatus isEqualToString:@"SOLD"] ||
       [self.processStatus isEqualToString:@"SUSPENDED"])
    {
        return ProductTypeSelling;
    }
    
    else if([self.processStatus isEqualToString:@"SOLD_CONFIRMED"] ||
            [self.processStatus isEqualToString:@"RECEIVED"] ||
            [self.processStatus isEqualToString:@"AUTHENTICATED"] ||
            [self.processStatus isEqualToString:@"SENT_TO_BUYER"] ||
            [self.processStatus isEqualToString:@"PRODUCT_NOT_AVAILABLE"] ||
            [self.processStatus isEqualToString:@"RECEIVED_BY_BUYER"] ||
            [self.processStatus isEqualToString:@"PAYOUT_SELLER"] ||
            [self.processStatus isEqualToString:@"PAYMENT_SENT"] ||
            [self.processStatus isEqualToString:@"REIMBURSE_BUYER"] ||
            [self.processStatus isEqualToString:@"RETURNED_BY_BUYER"] ||
            [self.processStatus isEqualToString:@"REJECTED_SEND_BACK"] ||
            [self.processStatus isEqualToString:@"COMPLETE"] ||
            [self.processStatus isEqualToString:@"PAYMENT_IN_CREDITS"]||
            [self.processStatus isEqualToString:@"PAYMENT_FAILED"])
    {
        return ProductTypeSold;
    }
    else if([self.processStatus isEqualToString:@"ARCHIVED"] ||
            [self.processStatus isEqualToString:@"DELETED"])
    {
        return ProductTypeArchived;
    }
    
    return ProductTypeNonVisible;
}

-(NSString*)getProductStatus
{
    NSString *res = @"Incompleted";
    if ([_processStatus isEqualToString:@"in_review"])
        res = @"In review";
    if ([_processStatus isEqualToString:@"in_review_add"])
        res = @"In review add";
    return res;
}

-(EditingType)getEditingType {
    if([self.processStatus isEqualToString:@"in_review"] ||
       [self.processStatus isEqualToString:@"in_review_add"] ||
       [self.processStatus isEqualToString:@"incomplete"] ||
       self.processStatus.length == 0)
    {
        return EditingTypeAll;
    }
    else if([self.processStatus isEqualToString:@"image_processing"] ||
            [self.processStatus isEqualToString:@"selling"])
    {
        return EditingTypeDescriptionAndCondition;
    }
    else
    {
        return EditingTypeNothing;
    }
}

//Implementation of NSCopying Protocol
- (id)copyWithZone:(NSZone *)zone{
    Product *newProduct = [[Product allocWithZone:zone]init];
    newProduct.identifier = _identifier;
    newProduct.type = _type;
    newProduct.name = [_name copy];
    newProduct.processStatus = [_processStatus copy];
    newProduct.processStatusDisplay = [_processStatusDisplay copy];
    newProduct.processComment = [_processComment copy];
    newProduct.category = [_category copy];
    newProduct.photos = [_photos mutableCopy];
    newProduct.designer = [_designer copy];
    newProduct.condition = [_condition copy];
    newProduct.originalPrice = _originalPrice;
    newProduct.suggestedPrice = _suggestedPrice;
    newProduct.price = _price;
    newProduct.allowedTransitions = [_allowedTransitions mutableCopy];
    newProduct.descriptionText = [_descriptionText copy];
    newProduct.unit = [_unit copy];
    newProduct.size = [_size copy];
    newProduct.sizeId = _sizeId;
    newProduct.kidzsize = _kidzsize;
    newProduct.shoeSize = [_shoeSize copy];
    newProduct.heelHeight = [_heelHeight copy];
    newProduct.dimensions = [_dimensions copy];
    return newProduct;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]){
        Product *product = (Product *) object;
        if (!(product.identifier && _identifier && product.identifier == _identifier)){
            if (!(!product.identifier && !_identifier)) {
                return NO;
            }
        }
        
        if (!(product.type && _type && product.type == _type)){
            if (!(!product.type && !_type)) {
                return NO;
            }
        }
        
        if (!(product.name && _name && [product.name isEqualToString:_name])){
            if (!(!product.name && !_name)) {
                return NO;
            }
        }
        
        if (!(product.processStatus && _processStatus && [product.processStatus isEqualToString:_processStatus])){
            if (!(!product.processStatus && ! _processStatus)) {
                return NO;
            }
        }
        if (!(product.processStatusDisplay && _processStatusDisplay && [product.processStatusDisplay isEqualToString:_processStatusDisplay])){
            if (!(!product.processStatusDisplay && !_processStatusDisplay)) {
                return NO;
            }
        }
        
        if (!(product.processComment && _processComment && [product.processComment isEqualToString:_processComment])){
            if (!(!product.processComment && !_processComment)) {
                return NO;
            }
        }
        
        if (!(product.category && _category && [product.category isEqual:_category])){
            if (!(!product.category && !_category)) {
                return NO;
            }
        }
        
        if (!(product.photos && _photos && [product.photos isEqualToArray:_photos])){
            if (!(!product.photos && !_photos)) {
                return NO;
            }
        }
        
        if (!(product.designer && _designer && [product.designer isEqual:_designer])){
            if (!(!product.designer && !_designer)) {
                return NO;
            }
        }
        
        if (!(product.condition && _condition && [product.condition isEqual:_condition])){
            if (!(!product.condition && !_condition)) {
                return NO;
            }
        }
        
        if (!(product.originalPrice && _originalPrice && product.originalPrice == _originalPrice)){
            if (!(!product.originalPrice && !_originalPrice)) {
                return NO;
            }
        }
        
        if (!(product.suggestedPrice && _suggestedPrice && product.suggestedPrice == _suggestedPrice)){
            if (!(!product.suggestedPrice && !_suggestedPrice)) {
                return NO;
            }
        }
        
        if (!(product.price && _price && product.price == _price)){
            if (!(!product.price && !_price)) {
                return NO;
            }
        }
        
        if (!(product.allowedTransitions && _allowedTransitions && [product.allowedTransitions isEqualToArray:_allowedTransitions])){
            if (!(!product.allowedTransitions && !_allowedTransitions)) {
                return NO;
            }
        }
        
        if (!(product.descriptionText && _descriptionText && [product.descriptionText isEqualToString:_descriptionText])){
            if (!(!product.descriptionText && !_descriptionText)) {
                return NO;
            }
        }
        
        if (!(product.unit && _unit && [product.unit isEqualToString:_unit])){
            if (!(!product.unit && !_unit)) {
                return NO;
            }
        }
        
        if (!(product.size && _size && [product.size isEqualToString:_size])){
            if (!(!product.size && !_size)) {
                return NO;
            }
        }
        
        if (!(product.kidzsize && _kidzsize && [product.kidzsize isEqualToString:_kidzsize])){
            if (!(!product.kidzsize && !_kidzsize)) {
                return NO;
            }
        }
        
        if (!(product.sizeId && _sizeId && product.sizeId == _sizeId)){
            if (!(!product.sizeId && !_sizeId)) {
                return NO;
            }
        }
        
        if (!(product.shoeSize && _shoeSize && [product.shoeSize isEqual:_shoeSize])){
            if (!(!product.shoeSize && !_shoeSize)) {
                return NO;
            }
        }
        
        if (!(product.heelHeight && _heelHeight && [product.heelHeight isEqualToString: _heelHeight])){
            if (!(!product.heelHeight && !_heelHeight)) {
                return NO;
            }
        }
        
        if (!(product.dimensions && _dimensions && [product.dimensions isEqualToArray:_dimensions]) ){
            if (!(!product.dimensions && !_dimensions)) {
                return NO;
            }
        }
    }else{
        return NO;
    }
    return YES;
}

@end
